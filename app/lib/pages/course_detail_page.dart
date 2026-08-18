import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'course_order_page.dart';

class CourseDetailPage extends StatefulWidget {
  final int id;
  const CourseDetailPage({super.key, required this.id});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.courseDetail(widget.id);
    setState(() {
      _detail = res['data'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = _detail?['price'] ?? 0;
    final title = _detail?['title']?.toString() ?? '课程详情';
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 260,
                            color: const Color(0xFFFFCC80),
                            child: const Center(child: FaIcon(FontAwesomeIcons.graduationCap, size: 80, color: Colors.white)),
                          ),
                          Positioned(
                            top: 40,
                            left: 12,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 120,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: Text(_detail?['categoryName']?.toString() ?? _detail?['category']?.toString() ?? '热门课程', style: const TextStyle(color: AppStyles.primary)),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 56,
                            child: Text('¥$price', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00))),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                        margin: const EdgeInsets.only(top: -20),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text((_detail?['teacher']?.toString() ?? '').isNotEmpty ? '主讲老师：${_detail?['teacher']}' : '优童金牌师资，陪伴孩子快乐成长', style: const TextStyle(color: AppStyles.primary)),
                            const SizedBox(height: 16),
                            _block('课程介绍', '本课程由优童教研团队精心设计，结合儿童身心发展规律，以游戏化、场景化的方式激发孩子的兴趣。通过专业引导与趣味互动，帮助孩子在轻松愉快的氛围中获得成长。'),
                            _block('课程特色', '1. 小班教学，因材施教，关注每一位孩子。\n2. 游戏化课堂，寓教于乐，提升参与感。\n3. 专业师资，定期反馈学习进度。\n4. 家校联动，帮助家长掌握科学育儿方法。'),
                            _block('温馨提示', '课程名额有限，报名后请按时参加。如遇特殊情况无法到场，请提前联系门店客服调整时间，感谢您的理解与支持。'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('参考价格', style: TextStyle(fontSize: 12, color: AppStyles.textLight)),
                            Text('¥$price', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00))),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourseOrderPage(id: widget.id))),
                            style: AppStyles.primaryButton,
                            child: const Text('立即报名'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _block(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 15, color: AppStyles.textSub, height: 1.8)),
      ],
    );
  }
}
