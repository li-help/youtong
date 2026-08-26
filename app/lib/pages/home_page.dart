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
import 'video_page.dart';
import 'smart_page.dart';
import 'course_detail_page.dart';
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
  List<dynamic> _services = [];
  List<dynamic> _recommends = [];
  bool _loading = true;
  bool _error = false;

  Timer? _versionTimer;
  int _lastVersion = 0;

  List<dynamic> _categories = [];

  static const Map<String, Map<String, String>> _categoryIcons = {
    '兴趣培养': {'emoji': '🎨', 'bg': '#FFE0B2'},
    '学科辅导': {'emoji': '📚', 'bg': '#FFCC80'},
    '绘画': {'emoji': '🎨', 'bg': '#FFE0B2'},
    '音乐': {'emoji': '🎵', 'bg': '#FFE082'},
    '数学': {'emoji': '🧮', 'bg': '#FFB74D'},
    '英语': {'emoji': '💬', 'bg': '#FFCC80'},
    '绘本阅读': {'emoji': '📖', 'bg': '#FFE0B2'},
    '益智游戏': {'emoji': '🧩', 'bg': '#FFCC80'},
    '科学启蒙': {'emoji': '🔬', 'bg': '#FFB74D'},
    '艺术创作': {'emoji': '🎨', 'bg': '#FFD54F'},
    '运动健康': {'emoji': '⚽', 'bg': '#FFB74D'},
    '音乐律动': {'emoji': '🎵', 'bg': '#FFE082'},
    '语言表达': {'emoji': '💬', 'bg': '#FFCC80'},
    '视频课程': {'emoji': '📺', 'bg': '#E3F2FD'},
    '创意绘画': {'emoji': '🎨', 'bg': '#FCE4EC'},
  };

  List<Map<String, dynamic>> _defaultCategories() {
    return [
      {'id': 1, 'name': '视频课程', 'emoji': '📺', 'bg': '#E3F2FD'},
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
    _versionTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollVersion());
  }

  @override
  void dispose() {
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
    setState(() { _loading = true; _error = false; });
    try {
      final results = await Future.wait([
        ApiService.listBanners(),
        ApiService.listVideos(page: 1, pageSize: 6),
        ApiService.listStores(page: 1, pageSize: 6),
        ApiService.listServices(page: 1, pageSize: 6),
        ApiService.recommendCourses(size: 4),
        ApiService.listCategories(page: 1, pageSize: 8),
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
        _services = results.length > 3 ? _listFrom(results[3]) : [];
        _recommends = results.length > 4 ? _listFrom(results[4]) : [];
        final cats = results.length > 5 ? _listFrom(results[5]) : [];
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
          const Center(child: AppSkeleton(width: 60, height: 24, borderRadius: 4)),
          const SizedBox(height: 16),
          const AppSkeleton(height: 180, borderRadius: 24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  AppSkeleton(width: 60, height: 60, borderRadius: 30),
                  SizedBox(height: 8),
                  AppSkeleton(width: 50, height: 14, borderRadius: 4),
                ],
              ),
            )),
          ),
          const SizedBox(height: 20),
          const AppSkeleton(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: const SkeletonGridCard(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const AppSkeleton(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          const AppSkeleton(height: 160, borderRadius: 24),
          const SizedBox(height: 16),
          const AppSkeleton(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const SkeletonGridCard(),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: _banners.isEmpty ? 1 : _banners.length,
            itemBuilder: (context, i) {
              final img = _banners.isEmpty ? null : _banners[i]['image']?.toString();
              if (img != null && img.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: AppNetworkImage(url: img, fit: BoxFit.cover, width: double.infinity),
                );
              }
              final title = _banners.isEmpty
                  ? '优童成长计划'
                  : (_banners[i]['title']?.toString() ?? '优童成长计划');
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppStyles.orangeSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(title,
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _sectionTitle('🎯 学习天地'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _categories
                .map((c) => Expanded(child: _categoryItem(Map<String, dynamic>.from(c as Map))))
                .toList(),
          ),
        ),
        _sectionTitle('⭐ 精选视频'),
        SizedBox(
          height: 220,
          child: _videos.isEmpty
              ? const AppEmptyState(title: '暂无视频')
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _videos.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => pushAppPage(context,
                        page: VideoPage(id: (_videos[i]['id'] as num).toInt())),
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AppNetworkImage(
                              url: _videos[i]['cover']?.toString(),
                              width: 150,
                              height: 180,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_videos[i]['title']?.toString() ?? '视频',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppStyles.textMain)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        _sectionTitle('🔥 为你推荐'),
        SizedBox(
          height: 188,
          child: _recommends.isEmpty
              ? const AppEmptyState(title: '暂无推荐')
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommends.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => pushAppPage(context,
                        page: CourseDetailPage(id: (_recommends[i]['id'] as num).toInt())),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              url: _recommends[i]['cover']?.toString(),
                              width: 140,
                              height: 110,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_recommends[i]['title']?.toString() ?? '课程',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppStyles.textMain)),
                          Text('¥${_recommends[i]['price'] ?? 0}', style: const TextStyle(fontSize: 13, color: AppStyles.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        _sectionTitle('🚀 小宇宙计划'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => pushAppPage(context, page: const SmartPage()),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2-3岁', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF57C00))),
                        SizedBox(height: 8),
                        Text('养成生活习惯\n发展语言与动作', style: TextStyle(fontSize: 13, color: Color(0xFF8A6D3B))),
                        SizedBox(height: 12),
                        Text('了解详情 ›', style: TextStyle(fontSize: 13, color: Color(0xFFF57C00), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    const ['1-2岁', '3-4岁'],
                    const ['4-5岁', '5-6岁'],
                  ].map((row) => Row(
                    children: row.map((age) => Expanded(
                      child: Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => pushAppPage(ctx, page: SmartPage(initialAge: age)),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Text(age, textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    )).toList(),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        _sectionTitle('🏪 附近门店', onMore: () => pushAppPage(context, page: const ServicePage(title: '附近门店'))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _stores.isEmpty
              ? const AppEmptyState(title: '暂无门店')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _stores.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () {
                      final id = _stores[i]['id'];
                      if (id is int && id > 0) {
                        pushAppPage(context, page: StoreDetailPage(id: id));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('店铺信息暂不可用')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppStyles.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AppNetworkImage(
                                url: (_stores[i]['cover'] ?? _stores[i]['image'] ?? _stores[i]['logo'])?.toString(),
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_stores[i]['name']?.toString() ?? '门店', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.solidStar, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${_stores[i]['score'] ?? 4.7}', style: const TextStyle(color: AppStyles.primary, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        _sectionTitle('💡 热门服务', onMore: () => pushAppPage(context, page: const ServicePage())),
        SizedBox(
          height: 120,
          child: _services.isEmpty
              ? const AppEmptyState(title: '暂无服务')
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _services.length,
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => pushAppPage(context, page: const ServicePage()),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: AppStyles.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_services[i]['name']?.toString() ?? '服务', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(_services[i]['description']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppStyles.textSub)),
                          const Spacer(),
                          Text(_services[i]['phone']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppStyles.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
          const Spacer(),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: const Text('查看更多 >', style: TextStyle(fontSize: 13, color: AppStyles.primary)),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
            child: Text(c['emoji']?.toString() ?? '⭐', style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 6),
          Text(c['name']?.toString() ?? '', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
        ],
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
