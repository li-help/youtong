import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
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
  String _summary = '';
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _failed = false; });
    try {
      final res = await ApiService.aiRecommend(age: widget.age, interests: '运动');
      if (!mounted) return;
      setState(() {
        final data = res['data'] as Map<String, dynamic>? ?? {};
        _summary = data['summary']?.toString() ?? '';
        _courses = data['courses'] is List ? data['courses'] as List : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _failed = true; });
    }
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
                  AppBackButton(),
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
                  Text('宝宝：${widget.age} · 身高${widget.height}cm · 体重${widget.weight}kg', style: const TextStyle(color: AppStyles.textSub)),
                  if (_summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_summary, style: const TextStyle(color: AppStyles.textMain, height: 1.5)),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('推荐课程', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: _loading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 4,
                      itemBuilder: (_, __) => const SkeletonListTile(hasImage: true),
                    )
                  : _failed
                      ? AppErrorRetry(onRetry: _load)
                      : _courses.isEmpty
                          ? const AppEmptyState(title: '暂无推荐课程', subtitle: '完善宝宝档案后再来试试吧')
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _courses.length,
                              itemBuilder: (context, i) => GestureDetector(
                                onTap: () => Navigator.of(context).push(AppPageRoute(
                                  builder: (_) => CourseDetailPage(id: _courses[i]['id'] is num ? (_courses[i]['id'] as num).toInt() : int.tryParse(_courses[i]['id']?.toString() ?? '') ?? 0),
                                )),
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
                                          color: [AppStyles.orangeSoft, const Color(0xFFEF9A9A), const Color(0xFFA5D6A7), const Color(0xFFFFF59D)][i % 4],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const FaIcon(FontAwesomeIcons.graduationCap, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_courses[i]['title']?.toString() ?? '课程', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            const Text('根据宝宝的年龄与兴趣智能匹配，助力快乐成长。', style: TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('参考价格 ¥${_courses[i]['price'] ?? 0}', style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                                Text(_courses[i]['categoryId']?.toString() ?? '推荐', style: const TextStyle(fontSize: 12, color: AppStyles.textLight)),
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
