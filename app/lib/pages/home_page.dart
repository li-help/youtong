import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'video_page.dart';
import 'smart_page.dart';
import 'course_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _banners = [];
  static const List<Color> _bannerColors = [
    Color(0xFFFFCC80),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': '视频课程', 'icon': Icons.play_circle_outline, 'color': const Color(0xFFFFECB3)},
    {'name': '创意绘画', 'icon': Icons.palette_outlined, 'color': const Color(0xFFF8BBD0)},
    {'name': '音乐启蒙', 'icon': Icons.music_note_outlined, 'color': const Color(0xFFE1BEE7)},
    {'name': '益智游戏', 'icon': Icons.extension_outlined, 'color': const Color(0xFFC5CAE9)},
  ];

  List<dynamic> _videos = [];
  List<dynamic> _stores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bRes = await ApiService.listBanners();
      final vRes = await ApiService.listVideos(page: 1, size: 6);
      final sRes = await ApiService.listStores(page: 1, size: 6);
      final ads = (bRes['data'] as List?) ?? [];
      setState(() {
        _banners = ads.whereType<Map<String, dynamic>>().toList();
        _videos = vRes['data']?['list'] ?? [];
        _stores = sRes['data']?['list'] ?? [];
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
                    SizedBox(
                      height: 180,
                      child: PageView.builder(
                        itemCount: _banners.isEmpty ? 1 : _banners.length,
                        itemBuilder: (context, i) {
                          final img = _banners.isEmpty ? null : _banners[i]['image']?.toString();
                          if (img != null && img.isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(img, fit: BoxFit.cover, width: double.infinity),
                            );
                          }
                          final title = _banners.isEmpty
                              ? '优童成长计划'
                              : (_banners[i]['title']?.toString() ?? '优童成长计划');
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: _banners.isEmpty ? const Color(0xFFFFCC80) : _bannerColors[i % _bannerColors.length],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
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
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => VideoPage(id: _videos[i]['id'] as int),
                          )),
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: [const Color(0xFFFFCC80), const Color(0xFFEF9A9A), const Color(0xFFA5D6A7)][i % 3],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _videos[i]['title']?.toString() ?? '视频',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: AppStyles.textMain),
                                ),
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
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(24),
                      ),
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
                                      child: Text(age, textAlign: TextAlign.center, style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                )).toList(),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _sectionTitle('🏪 优质店铺'),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: [const Color(0xFFFFE082), const Color(0xFFFFCC80), const Color(0xFFFFAB91), const Color(0xFFBCAAA4)][i % 4],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_stores[i]['name']?.toString() ?? '店铺', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Text('${_stores[i]['score'] ?? 4.7}分', style: const TextStyle(color: AppStyles.primary, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppStyles.bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppStyles.primaryLight)),
                                    child: const Text('宝宝专属', style: TextStyle(fontSize: 10, color: AppStyles.primary)),
                                  ),
                                ],
                              ),
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
