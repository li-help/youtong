import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
      resp = await http.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
    } else if (method == 'DELETE') {
      resp = await http.delete(uri, headers: headers);
    } else {
      resp = await http.get(uri, headers: headers);
    }

    if (resp.statusCode == 401) {
      await clearToken();
      throw Exception('登录已过期');
    }
    final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return data;
  }

  static Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      request('GET', path, query: query);
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      request('POST', path, body: body);
  static Future<Map<String, dynamic>> delete(String path) => request('DELETE', path);

  // Auth
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return post('/auth/login', body: {'username': username, 'password': password});
  }

  static Future<Map<String, dynamic>> logout() => post('/auth/logout');
  static Future<Map<String, dynamic>> info() => post('/auth/info');

  // Resources
  static Future<Map<String, dynamic>> listVideos({int page = 1, int size = 20}) =>
      get('/video', query: {'page': '$page', 'size': '$size'});
  static Future<Map<String, dynamic>> videoDetail(int id) => get('/video/$id');

  static Future<Map<String, dynamic>> listCourses({int page = 1, int size = 20}) =>
      get('/course', query: {'page': '$page', 'size': '$size'});
  static Future<Map<String, dynamic>> courseDetail(int id) => get('/course/$id');

  static Future<Map<String, dynamic>> listActivities({int page = 1, int size = 20}) =>
      get('/activity', query: {'page': '$page', 'size': '$size'});
  static Future<Map<String, dynamic>> activityDetail(int id) => get('/activity/$id');

  static Future<Map<String, dynamic>> listStores({int page = 1, int size = 20}) =>
      get('/store', query: {'page': '$page', 'size': '$size'});

  static Future<Map<String, dynamic>> listCategories({int page = 1, int size = 20}) =>
      get('/category', query: {'page': '$page', 'size': '$size'});

  static Future<Map<String, dynamic>> listOrders({int page = 1, int size = 20, int? status}) =>
      get('/order', query: {'page': '$page', 'size': '$size', if (status != null) 'status': '$status'});

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) =>
      post('/order/create', body: body);
}
