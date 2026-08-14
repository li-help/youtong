import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'course_detail_page.dart';

class SmartResultPage extends StatefulWidget {
  final String age;
  final int height;
  final int weight;
  const SmartResultPage({super.key, required this.age, required this.height, required this.weight});

  @override
  State<SmartResultPage> createState() => _SmartResultPageState();
}

class _SmartResultPageState extends State<SmartResultPage> {
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.listCourses(page: 1, pageSize: 20);
    setState(() {
      _courses = res['data']?['list'] ?? [];
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
                  const Expanded(child: Text('推荐课程', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('智能推荐结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Chip(label: Text('偏瘦体质'), backgroundColor: Color(0xFFFFF8E1)),
                  Text('您的宝宝是一个${widget.age}、身高${widget.height}cm、体重${widget.weight}kg的宝宝', style: const TextStyle(color: AppStyles.textSub)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('推荐课程', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _courses.length,
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseDetailPage(id: (_courses[i]['id'] is num ? (_courses[i]['id'] as num).toInt() : int.tryParse(_courses[i]['id']?.toString() ?? '') ?? 0))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppStyles.cardDecoration,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: [const Color(0xFFFFCC80), const Color(0xFFEF9A9A), const Color(0xFFA5D6A7), const Color(0xFFFFF59D)][i % 4],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.school, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_courses[i]['title']?.toString() ?? '课程', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Text('优质课程，适合宝宝成长学习。', style: TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('参考价格 ¥${_courses[i]['price'] ?? 0}', style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                        Text('${[1000, 1888, 2000, 1500][i % 4]}人浏览', style: const TextStyle(fontSize: 12, color: AppStyles.textLight)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
