import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import 'video_page.dart';
import 'smart_page.dart';
import 'course_page.dart';
import 'course_detail_page.dart';

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

  final List<Map<String, dynamic>> _categories = [
    {'name': '视频课程', 'icon': Icons.play_circle_outline, 'color': const Color(0xFFFFECB3)},
    {'name': '创意绘画', 'icon': Icons.palette_outlined, 'color': const Color(0xFFF8BBD0)},
    {'name': '音乐启蒙', 'icon': Icons.music_note_outlined, 'color': const Color(0xFFE1BEE7)},
    {'name': '益智游戏', 'icon': Icons.extension_outlined, 'color': const Color(0xFFC5CAE9)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.listBanners(),
        ApiService.listVideos(page: 1, pageSize: 6),
        ApiService.listStores(page: 1, pageSize: 6),
        ApiService.listServices(page: 1, pageSize: 6),
        ApiService.recommendCourses(size: 4),
      ]);
      setState(() {
        final banners = results[0]['data'];
        _banners = banners is List ? banners : [];
        _videos = results[1]['data']?['list'] ?? [];
        _stores = results[2]['data']?['list'] ?? [];
        _services = results[3]['data']?['list'] ?? [];
        _recommends = results[4]['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('优童', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    // 真实 banner（后台广告位 home_banner）
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
                              color: const Color(0xFFFFCC80),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _categories.map((c) => _categoryItem(c)).toList(),
                      ),
                    ),
                    _sectionTitle('⭐ 精选视频'),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _videos.length,
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => VideoPage(id: (_videos[i]['id'] as num).toInt()))),
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
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _recommends.length,
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CourseDetailPage(id: (_recommends[i]['id'] as num).toInt()))),
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AppNetworkImage(
                                    url: _recommends[i]['cover']?.toString(),
                                    width: 150,
                                    height: 110,
                                    borderRadius: BorderRadius.circular(16),
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
                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SmartPage())),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('2-3岁', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppStyles.primary)),
                                    SizedBox(height: 8),
                                    Text('养成生活习惯\n发展语言与动作', style: TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                    SizedBox(height: 12),
                                    Chip(label: Text('了解课程', style: TextStyle(color: Color(0xFFB86E00))), backgroundColor: Color(0xFFFFE082)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: const [
                                ['1-2岁', '3-4岁'],
                                ['4-5岁', '5-6岁'],
                              ].map((row) => Row(
                                children: row.map((age) => Expanded(
                                  child: GestureDetector(
                                    onTap: () => null,
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                      child: Text(age, textAlign: TextAlign.center,
                                          style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                )).toList(),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _sectionTitle('🏪 附近门店'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _stores.length,
                        itemBuilder: (context, i) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppStyles.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppNetworkImage(
                                    url: _stores[i]['image']?.toString(),
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
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('${_stores[i]['score'] ?? 4.7}', style: const TextStyle(color: AppStyles.primary, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _sectionTitle('💡 热门服务'),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _services.length,
                        itemBuilder: (context, i) => Container(
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
          const Spacer(),
          const Text('查看更多 >', style: TextStyle(fontSize: 13, color: AppStyles.primary)),
        ],
      ),
    );
  }

  Widget _categoryItem(Map<String, dynamic> c) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoursePage())),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: c['color'] as Color, borderRadius: BorderRadius.circular(30)),
            child: Icon(c['icon'] as IconData, color: AppStyles.textMain),
          ),
          const SizedBox(height: 6),
          Text(c['name'] as String, style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
        ],
      ),
    );
  }
}
