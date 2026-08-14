import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import 'course_detail_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<dynamic> _courses = [];
  List<dynamic> _categories = [];
  int? _activeCat;
  String _keyword = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiService.listCourses(page: 1, pageSize: 20, keyword: _keyword, categoryId: _activeCat),
      ApiService.listCategories(page: 1, pageSize: 50),
    ]);
    setState(() {
      _courses = results[0]['data']?['list'] ?? [];
      _categories = results[1]['data']?['list'] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => _keyword = v,
                      onSubmitted: (_) => _load(),
                      decoration: InputDecoration(
                        hintText: '课程名称',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _load(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppStyles.primaryLight, borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _categories.isEmpty ? 0 : 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    final all = _activeCat == null;
                    return _catChip('全部', all, () => setState(() {
                          _activeCat = null;
                          _load();
                        }));
                  }
                  final c = _categories[i - 1];
                  final active = _activeCat == c['id'];
                  return _catChip(c['name']?.toString() ?? '分类', active, () => setState(() {
                        _activeCat = c['id'] as int?;
                        _load();
                      }));
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('🔥 热销课程 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                  : _courses.isEmpty
                      ? const Center(child: Text('暂无课程', style: TextStyle(color: AppStyles.textSub)))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _courses.length,
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => CourseDetailPage(id: (_courses[i]['id'] as num).toInt()))),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: AppStyles.cardDecoration,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: AppNetworkImage(
                                            url: _courses[i]['cover']?.toString(),
                                            width: double.infinity,
                                            height: double.infinity,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        Positioned(
                                          left: 4,
                                          top: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            color: AppStyles.bg,
                                            child: const Text('自营', style: TextStyle(fontSize: 10, color: AppStyles.primary)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_courses[i]['title']?.toString() ?? '课程', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                                  Text('¥${_courses[i]['price'] ?? 0}', style: const TextStyle(fontSize: 12, color: AppStyles.primary)),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catChip(String name, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: active ? AppStyles.primary : AppStyles.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.category, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
