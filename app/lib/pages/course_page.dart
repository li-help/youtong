import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'course_detail_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<dynamic> _courses = [];
  List<dynamic> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cRes = await ApiService.listCourses(page: 1, pageSize: 20);
    final catRes = await ApiService.listCategories(page: 1, pageSize: 20);
    setState(() {
      _courses = cRes['data']?['list'] ?? [];
      _categories = catRes['data']?['list'] ?? [];
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppStyles.primaryLight, borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, i) => Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: [const Color(0xFFFFCC80), const Color(0xFFEF9A9A), const Color(0xFFA5D6A7), const Color(0xFFFFF59D)][i % 4],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.category, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(_categories[i]['name']?.toString() ?? '分类', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔥 热销课程 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
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
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseDetailPage(id: _courses[i]['id'] as int))),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: AppStyles.cardDecoration,
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: [const Color(0xFFFFCC80), const Color(0xFFEF9A9A), const Color(0xFFA5D6A7)][i % 3],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(child: Icon(Icons.school, color: Colors.white, size: 40)),
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
}
