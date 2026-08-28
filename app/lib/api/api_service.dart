import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// 后端地址：
  /// - Web 端：使用相对路径 /api（同源，由 Nginx 反代到后端 3001），无需硬编码域名
  /// - 移动端：优先使用编译期注入（--dart-define=API_BASE_URL=...），
  ///   未注入时回退到已上线生产环境（Nginx 反代 /api），确保 release 包默认可连。
  ///   本地联调请注入：--dart-define=API_BASE_URL=http://10.0.2.2:3001/api
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      // Web 端：线上部署用相对路径 /api（由 Nginx 反代到后端），
      // 本地调试（flutter run -d chrome）时 Flutter 开发服务器跑在 localhost，
      // 相对路径 /api 会指向 localhost 导致 404，需回退到真实后端地址
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://123.56.160.50/api';
      }
      return '/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 安卓模拟器访问宿主机：优先本地联调地址，联调时仍可通过 --dart-define 覆盖
      return 'http://123.56.160.50/api';
    }
    return 'http://123.56.160.50/api';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// WebSocket 基地址：由 baseUrl 推导（http://xxx/api -> ws://xxx），
  /// 用于客服 IM 通道 /ws/im。可用 --dart-define=API_WS_URL 覆盖。
  static String get wsBaseUrl {
    const fromEnv = String.fromEnvironment('API_WS_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    final base = baseUrl;
    if (base.startsWith('/')) {
      // Web 同源相对路径：按当前页面地址推导
      final u = Uri.base;
      final scheme = u.scheme == 'https' ? 'wss' : 'ws';
      final defaultPort = (u.scheme == 'https' && u.port == 443) ||
          (u.scheme == 'http' && u.port == 80);
      return '$scheme://${u.host}${defaultPort ? '' : ':${u.port}'}';
    }
    if (base.startsWith('https://')) {
      return base.replaceFirst('https://', 'wss://').replaceFirst(RegExp(r'/api$'), '');
    }
    return base.replaceFirst('http://', 'ws://').replaceFirst(RegExp(r'/api$'), '');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userInfo');
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('userInfo');
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<void> setUserInfo(Map<String, dynamic> info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(info));
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    Uri uri = Uri.parse(baseUrl + path);
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    late final http.Response resp;
    if (method == 'GET') {
      resp = await http.get(uri, headers: headers);
    } else if (method == 'POST') {
      resp = await http.post(uri,
          headers: headers, body: body == null ? null : jsonEncode(body));
    } else if (method == 'DELETE') {
      resp = await http.delete(uri, headers: headers);
    } else {
      resp = await http.get(uri, headers: headers);
    }

    if (resp.statusCode == 401) {
      await clearToken();
      throw Exception('登录已过期');
    }
    final data =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return data;
  }

  static Future<Map<String, dynamic>> get(String path,
          {Map<String, String>? query}) =>
      request('GET', path, query: query);
  static Future<Map<String, dynamic>> post(String path,
          {Map<String, dynamic>? body}) =>
      request('POST', path, body: body);
  static Future<Map<String, dynamic>> delete(String path) =>
      request('DELETE', path);

  // Auth
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    return post('/auth/login',
        body: {'username': username, 'password': password});
  }

  static Future<Map<String, dynamic>> register(String username, String password,
      {String? nickname, String? code}) async {
    return post('/auth/register', body: {
      'username': username,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      if (code != null && code.isNotEmpty) 'code': code,
    });
  }

  /// 发送短信验证码（演示环境后端会返回明文验证码，便于联调）
  static Future<Map<String, dynamic>> sendCode(String phone) async {
    return post('/auth/sendCode', body: {'phone': phone});
  }

  /// 校验验证码
  static Future<Map<String, dynamic>> checkCode(
      String phone, String code) async {
    return post('/auth/checkCode', body: {'phone': phone, 'code': code});
  }

  /// 通过手机号 + 验证码重置密码（忘记密码，无需原密码）
  static Future<Map<String, dynamic>> resetPwdByCode(
      String phone, String code, String newPassword) async {
    return post('/auth/resetPwdByCode',
        body: {'phone': phone, 'code': code, 'newPassword': newPassword});
  }

  static Future<Map<String, dynamic>> logout() => post('/auth/logout');
  static Future<Map<String, dynamic>> info() => post('/auth/info');

  /// 手机号 + 验证码登录（免密，未注册自动注册）
  static Future<Map<String, dynamic>> phoneLogin(String phone, String code) =>
      post('/auth/phoneLogin', body: {'phone': phone, 'code': code});

  // Resources（C 端列表统一走公开的 /list 接口，仅返回已上线内容）
  static Future<Map<String, dynamic>> listVideos(
          {int page = 1, int pageSize = 20}) =>
      get('/video/list',
          query: {'page': '$page', 'pageSize': '$pageSize', 'status': '1'});
  static Future<Map<String, dynamic>> videoDetail(int id) => get('/video/$id');

  static Future<Map<String, dynamic>> listCourses(
          {int page = 1,
          int pageSize = 20,
          String? keyword,
          int? categoryId}) =>
      get('/course/list', query: {
        'page': '$page',
        'pageSize': '$pageSize',
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (categoryId != null) 'categoryId': '$categoryId',
      });
  static Future<Map<String, dynamic>> courseDetail(int id) =>
      get('/course/$id');

  static Future<Map<String, dynamic>> listActivities(
          {int page = 1, int pageSize = 20}) =>
      get('/activity/list',
          query: {'page': '$page', 'pageSize': '$pageSize', 'status': '1'});
  static Future<Map<String, dynamic>> activityDetail(int id) =>
      get('/activity/$id');

  static Future<Map<String, dynamic>> listStores(
          {int page = 1, int pageSize = 20}) =>
      get('/store/list', query: {'page': '$page', 'pageSize': '$pageSize'});

  static Future<Map<String, dynamic>> listServices(
          {int page = 1, int pageSize = 20}) =>
      get('/service/list', query: {'page': '$page', 'pageSize': '$pageSize'});

  static Future<Map<String, dynamic>> listCategories(
          {int page = 1, int pageSize = 20}) =>
      get('/category/list',
          query: {'page': '$page', 'pageSize': '$pageSize', 'status': '1'});

  // C 端课程推荐
  static Future<Map<String, dynamic>> recommendCourses({int size = 6}) =>
      get('/course/recommend', query: {'size': '$size'});

  // 当前用户信息 / 修改资料（对接后端 sys_account）
  static Future<Map<String, dynamic>> userMe() => get('/user/me');
  static Future<Map<String, dynamic>> updateProfile(String nickname,
          {String? avatar}) =>
      post('/user/profile',
          body: {'nickname': nickname, if (avatar != null) 'avatar': avatar});

  /// 上传文件（multipart/form-data），对接后端 POST /api/upload。
  /// 返回 {code, msg, data: {url, type}}，url 为 /uploads/... 相对路径，
  /// 展示时经 AppNetworkImage.resolveUrl 自动拼接为完整地址。
  static Future<Map<String, dynamic>> uploadFile({
    required String filename,
    required List<int> bytes,
  }) async {
    final headers = <String, String>{};
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final req = http.MultipartRequest('POST', Uri.parse(baseUrl + '/upload'))
      ..headers.addAll(headers)
      ..files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final resp = await req.send();
    if (resp.statusCode == 401) {
      await clearToken();
      throw Exception('登录已过期');
    }
    final data = jsonDecode(utf8.decode(await resp.stream.toBytes()))
        as Map<String, dynamic>;
    return data;
  }

  // 用户统计（订单数/收藏数）
  static Future<Map<String, dynamic>> userStats() => get('/user/stats');

  // AI 智能助手
  static Future<Map<String, dynamic>> aiChat(
      List<Map<String, String>> messages) async {
    return post('/ai/chat', body: {'messages': messages})
        .timeout(const Duration(seconds: 60));
  }

  // AI 智能客服（FAQ 知识库匹配 + 多轮对话 + 转人工检测）
  static Future<Map<String, dynamic>> aiServiceChat({
    required String message,
    int? sessionId,
    String? clientMsgId,
  }) async {
    return post('/ai/service-chat', body: {
      'message': message,
      if (sessionId != null) 'sessionId': sessionId,
      if (clientMsgId != null) 'clientMsgId': clientMsgId,
    }).timeout(const Duration(seconds: 60));
  }

  // 客服 IM 会话
  static Future<Map<String, dynamic>> imInitSession({int storeId = 0}) =>
      get('/im/session/init', query: {'storeId': '$storeId'});

  static Future<Map<String, dynamic>> imHistory(int sessionId,
          {int page = 1, int pageSize = 30}) =>
      get('/im/message/history', query: {
        'sessionId': '$sessionId',
        'page': '$page',
        'pageSize': '$pageSize',
      });

  static Future<Map<String, dynamic>> imTransfer(int sessionId) =>
      post('/im/session/transfer', body: {'sessionId': sessionId});

  // 收藏
  static Future<Map<String, dynamic>> listFavorites({String? targetType}) =>
      get('/favorite/list', query: {
        if (targetType != null && targetType.isNotEmpty)
          'targetType': targetType
      });
  static Future<Map<String, dynamic>> addFavorite(Map<String, dynamic> body) =>
      post('/favorite/add', body: body);
  static Future<Map<String, dynamic>> removeFavorite(
          Map<String, dynamic> body) =>
      post('/favorite/remove', body: body);
  static Future<Map<String, dynamic>> favoriteStatus(
          String targetType, int targetId) =>
      get('/favorite/status',
          query: {'targetType': targetType, 'targetId': '$targetId'});

  // 收货地址
  static Future<Map<String, dynamic>> listAddresses() => get('/address/list');
  static Future<Map<String, dynamic>> saveAddress(Map<String, dynamic> body) =>
      post('/address/save', body: body);
  static Future<Map<String, dynamic>> deleteAddress(int id) =>
      delete('/address/$id');
  static Future<Map<String, dynamic>> setDefaultAddress(int id) =>
      post('/address/$id/default');

  // 资讯文章
  static Future<Map<String, dynamic>> listArticles(
          {int page = 1, int pageSize = 20, int? categoryId}) =>
      get('/article/published', query: {
        'page': '$page',
        'pageSize': '$pageSize',
        if (categoryId != null) 'categoryId': '$categoryId',
      });
  static Future<Map<String, dynamic>> articleDetail(int id) =>
      get('/article/view/$id');

  // 首页轮播：后台广告位 home_banner（统一走 /api/ad，与 uniapp 端一致）
  static Future<Map<String, dynamic>> listBanners() =>
      get('/ad/list', query: {'positionId': '1', 'status': '1'});

  static Future<Map<String, dynamic>> listOrders(
          {int page = 1, int pageSize = 20, String? status}) =>
      get('/order/list', query: {
        'page': '$page',
        'pageSize': '$pageSize',
        if (status != null) 'status': status
      });

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) =>
      post('/order/create', body: body);

  /// 订单核销（商家端）
  static Future<Map<String, dynamic>> verifyOrder(int id) =>
      post('/order/$id/verify');

  /// 模拟支付（待支付 -> 已支付）
  static Future<Map<String, dynamic>> payOrder(int id) =>
      post('/order/$id/pay');

  // AI 智能推荐（与 uniapp 端一致）
  static Future<Map<String, dynamic>> aiRecommend({
    String age = '0-1岁',
    String interests = '运动',
  }) async {
    return post('/ai/recommend', body: {'age': age, 'interests': interests});
  }

  // 数据版本号（用于轮询实时刷新，与后台编辑同步）
  static Future<Map<String, dynamic>> fetchVersion(String channel) async {
    return get('/sync/version', query: {'channel': channel});
  }
}
