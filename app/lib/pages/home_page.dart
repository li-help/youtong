import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_refresh_load.dart';
import '../widgets/app_page_route.dart';
import '../widgets/app_page_header.dart';
import 'video_page.dart';
import 'smart_page.dart';
import 'store_detail_page.dart';
import 'service_page.dart';
import 'article_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _banners = [];
  List<dynamic> _videos = [];
  List<dynamic> _stores = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  bool _error = false;

  final PageController _bannerController = PageController();
  int _bannerIndex = 0;

  Timer? _versionTimer;
  int _lastVersion = 0;

  static const Map<String, Map<String, String>> _categoryIcons = {
    '兴趣培养': {'emoji': '🎨', 'bg': '#FFE0B2'},
    '学科辅导': {'emoji': '📚', 'bg': '#FFCC80'},
    '绘画': {'emoji': '🎨', 'bg': '#FFE0B2'},
    '音乐': {'emoji': '🎵', 'bg': '#FFE082'},
    '数学': {'emoji': '🧮', 'bg': '#FFB74D'},
    '英语': {'emoji': '💬', 'bg': '#FFCC80'},
    '绘本阅读': {'emoji': '📖', 'bg': '#FFE0B2'},
    '益智游戏': {'emoji': '🧩', 'bg': '#E8F5E9'},
    '科学启蒙': {'emoji': '🔬', 'bg': '#FFB74D'},
    '艺术创作': {'emoji': '🎨', 'bg': '#FFD54F'},
    '运动健康': {'emoji': '⚽', 'bg': '#FFB74D'},
    '音乐律动': {'emoji': '🎵', 'bg': '#FFE082'},
    '语言表达': {'emoji': '💬', 'bg': '#FFCC80'},
    '视频课程': {'emoji': '📚', 'bg': '#E3F2FD'},
    '创意绘画': {'emoji': '🎨', 'bg': '#FCE4EC'},
    '音乐启蒙': {'emoji': '🎵', 'bg': '#FFF8E1'},
  };

  // 小宇宙计划右侧年龄格文字颜色（对应设计图：橙/绿/蓝/红）
  static const Map<String, Color> _ageColors = {
    '1-2岁': Color(0xFFFF9F2E),
    '3-4岁': Color(0xFF43A047),
    '4-5岁': Color(0xFF1E88E5),
    '5-6岁': Color(0xFF9C27B0),
  };

  // 显式指定中文字体，避免被系统里安装的试用版字体（带水印）兜底渲染。
  // Windows 用微软雅黑；Android/iOS 上无此字体时自动回退系统默认中文字体。
  static const String _cjkFont = 'Microsoft YaHei';

  List<Map<String, dynamic>> _defaultCategories() {
    return [
      {'id': 1, 'name': '视频课程', 'emoji': '📚', 'bg': '#E3F2FD'},
      {'id': 2, 'name': '创意绘画', 'emoji': '🎨', 'bg': '#FCE4EC'},
      {'id': 3, 'name': '音乐启蒙', 'emoji': '🎵', 'bg': '#FFF8E1'},
      {'id': 4, 'name': '益智游戏', 'emoji': '🧩', 'bg': '#E8F5E9'},
    ];
  }

  Map<String, dynamic> _decorateCategory(dynamic c) {
    final name = c is Map ? (c['name']?.toString() ?? '') : '';
    final icon = _categoryIcons[name] ?? {'emoji': '⭐', 'bg': '#FFE0B2'};
    return {
      'id': c is Map ? c['id'] : null,
      'name': name,
      'emoji': icon['emoji'],
      'bg': icon['bg'],
    };
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _versionTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _pollVersion());
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _versionTimer?.cancel();
    super.dispose();
  }

  List<dynamic> _listFrom(dynamic response) {
    if (response is! Map) return [];
    final data = response['data'];
    if (data is List) return data;
    if (data is Map && data['list'] is List) return data['list'] as List;
    return [];
  }

  Future<void> _pollVersion() async {
    try {
      final res = await ApiService.fetchVersion('home');
      final v = res['data'];
      if (v is num) {
        final version = v.toInt();
        if (_lastVersion != 0 && version != _lastVersion) {
          _loadData();
        }
        _lastVersion = version;
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final results = await Future.wait([
        ApiService.listBanners(),
        ApiService.listVideos(page: 1, pageSize: 6),
        ApiService.listStores(page: 1, pageSize: 8),
        ApiService.listCategories(page: 1, pageSize: 4),
      ]);
      setState(() {
        final banners = results.isNotEmpty ? results[0]['data'] : null;
        _banners = banners is List
            ? banners
            : (banners is Map
                ? (banners['list'] is List ? banners['list'] as List : [])
                : []);
        _videos = results.length > 1 ? _listFrom(results[1]) : [];
        _stores = results.length > 2 ? _listFrom(results[2]) : [];
        final cats = results.length > 3 ? _listFrom(results[3]) : [];
        _categories = cats.isEmpty
            ? _defaultCategories()
            : cats.map(_decorateCategory).toList();
        _loading = false;
        _error = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
        _categories = _defaultCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? _skeletonBody()
            : _error
                ? AppErrorRetry(onRetry: _loadData, message: '首页数据加载失败')
                : AppRefreshLoad(
                    onRefresh: _loadData,
                    enableLoadMore: false,
                    child: _body(),
                  ),
      ),
    );
  }

  Widget _skeletonBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: AppSkeleton(width: 60, height: 24, borderRadius: 4)),
          const SizedBox(height: 16),
          const AppSkeleton(height: 170, borderRadius: 16),
          const SizedBox(height: 20),
          const AppSkeleton(height: 130, borderRadius: 16),
          const SizedBox(height: 20),
          const AppSkeleton(height: 20, width: 100, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: const SkeletonGridCard(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const AppSkeleton(height: 150, borderRadius: 16),
          const SizedBox(height: 16),
          const AppSkeleton(height: 20, width: 100, borderRadius: 4),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const SkeletonGridCard(),
          ),
        ],
      ),
    );
  }

  // AppRefreshLoad 内部已有 SingleChildScrollView，这里直接返回滚动内容即可，
  // 不能再嵌套 Expanded（无界高度会抛 RenderFlex 异常）。
  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppPageHeader(title: '首页'),
        const SizedBox(height: 12),
        _banner(),
        const SizedBox(height: 12),
        _learningCard(),
        const SizedBox(height: 12),
        _videoCard(),
        const SizedBox(height: 12),
        _universeCard(),
        const SizedBox(height: 12),
        _storeCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // —— 轮播图 ——
  Widget _banner() {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _banners.isEmpty ? 1 : _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final img =
                  _banners.isEmpty ? null : _banners[i]['image']?.toString();
              if (img != null && img.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: AppNetworkImage(
                      url: img, fit: BoxFit.cover, width: double.infinity),
                );
              }
              final title = _banners.isEmpty
                  ? '优童成长计划'
                  : (_banners[i]['title']?.toString() ?? '优童成长计划');
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: AppStyles.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
          if (_banners.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (i) {
                  final active = i == _bannerIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? AppStyles.primary
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // —— 卡片通用标题行 ——
  Widget _cardHeader(Widget icon, String title,
      {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textMain)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action,
                  style:
                      const TextStyle(fontSize: 13, color: AppStyles.primary)),
            ),
        ],
      ),
    );
  }

  // —— 学习天地 ——
  Widget _learningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: AppStyles.cardDecoration
          .copyWith(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 左侧云朵装饰
          const Positioned(
            left: -10,
            top: 34,
            child: Text('☁️', style: TextStyle(fontSize: 30)),
          ),
          // 右下角星星装饰
          const Positioned(
            right: 10,
            bottom: 4,
            child: Text('⭐', style: TextStyle(fontSize: 14)),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _cardHeader(
                  const FaIcon(FontAwesomeIcons.bullseye,
                      color: Color(0xFFE53E3E), size: 18),
                  '学习天地',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Row(
                  children: _categories
                      .take(4)
                      .map((c) => Expanded(
                          child: _categoryItem(
                              Map<String, dynamic>.from(c as Map))))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(Map<String, dynamic> c) {
    final bg = _hexColor(c['bg']?.toString() ?? '#FFE0B2');
    final id = c['id'];
    return GestureDetector(
      onTap: () => pushAppPage(
        context,
        page: ArticleListPage(
          categoryId: id is num ? id.toInt() : int.tryParse(id.toString()),
          categoryName: c['name']?.toString(),
        ),
      ),
      // AspectRatio(1) 保证宫格为正方形
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(c['emoji']?.toString() ?? '⭐',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Flexible(
                child: Text(c['name']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppStyles.textMain)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // —— 精选视频 ——
  Widget _videoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: AppStyles.cardDecoration
          .copyWith(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            const FaIcon(FontAwesomeIcons.clapperboard,
                color: Color(0xFF37474F), size: 18),
            '精选视频',
          ),
          SizedBox(
            height: 190,
            child: _videos.isEmpty
                ? const AppEmptyState(title: '暂无视频')
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    itemCount: _videos.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => pushAppPage(context,
                          page:
                              VideoPage(id: (_videos[i]['id'] as num).toInt())),
                      child: Container(
                        width: 118,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppNetworkImage(
                                url: _videos[i]['cover']?.toString(),
                                fit: BoxFit.cover,
                              ),
                              // 左下角标题角标
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  color: Colors.black.withValues(alpha: 0.35),
                                  child: Text(
                                    _videos[i]['title']?.toString() ?? '视频',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // —— 小宇宙计划 ——
  Widget _universeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _cardHeader(
            const FaIcon(FontAwesomeIcons.rocket,
                color: AppStyles.primary, size: 18),
            '小宇宙计划',
            action: '查看更多 >',
            onAction: () => pushAppPage(context, page: const SmartPage()),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧 2-3岁 主卡
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () =>
                      pushAppPage(context, page: SmartPage(initialAge: '2-3岁')),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('2-3',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.primary,
                                    height: 1,
                                    fontFamily: _cjkFont)),
                            const Text('岁',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.primary,
                                    fontFamily: _cjkFont)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppStyles.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('推荐',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppStyles.primary,
                                      fontFamily: _cjkFont)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('养成生活习惯\n发展语言与动作',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8A6D3B),
                                height: 1.5,
                                fontFamily: _cjkFont)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('了解课程',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.primary,
                                    fontFamily: _cjkFont)),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 1,
                              height: 10,
                              color: AppStyles.line,
                            ),
                            const Expanded(
                              child: Text(
                                '3828人已解锁',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppStyles.textLight,
                                    fontFamily: _cjkFont),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 右侧 2x2 年龄格
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    const ['1-2岁', '3-4岁'],
                    const ['4-5岁', '5-6岁'],
                  ]
                      .map((row) => Row(
                            children: row
                                .map((age) => Expanded(
                                      child: Builder(
                                        builder: (ctx) => GestureDetector(
                                          onTap: () => pushAppPage(ctx,
                                              page: SmartPage(initialAge: age)),
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 22),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Text(age,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: _ageColors[age] ??
                                                        AppStyles.primary,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // —— 优质店铺 ——
  Widget _storeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.only(bottom: 14),
      decoration: AppStyles.cardDecoration
          .copyWith(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _cardHeader(
            const FaIcon(FontAwesomeIcons.store,
                color: Color(0xFF1E88E5), size: 18),
            '优质店铺',
            action: '查看全部',
            onAction: () =>
                pushAppPage(context, page: const ServicePage(title: '优质店铺')),
          ),
          if (_stores.isEmpty)
            const AppEmptyState(title: '暂无门店')
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: _stores.length,
                itemBuilder: (context, i) => _storeItem(_stores[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _storeItem(dynamic store) {
    final name = store['name']?.toString() ?? '门店';
    final score = store['score']?.toString() ?? '4.7';
    final cover =
        (store['cover'] ?? store['image'] ?? store['logo'])?.toString();
    final id = store['id'];
    return GestureDetector(
      onTap: () {
        if (id is int && id > 0) {
          pushAppPage(context, page: StoreDetailPage(id: id));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('店铺信息暂不可用')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppStyles.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: AppNetworkImage(
                    url: cover,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textMain)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(score,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primary)),
                const SizedBox(width: 2),
                const Text('分',
                    style: TextStyle(fontSize: 12, color: AppStyles.textLight)),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👶', style: TextStyle(fontSize: 10)),
                  SizedBox(width: 3),
                  Text('宝宝专属',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A6D3B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16) ?? 0xFFFFE0B2;
    return Color(v);
  }
}
