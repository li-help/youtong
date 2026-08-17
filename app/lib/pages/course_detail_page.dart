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
                            const Text('以球启智，以运动润心', style: TextStyle(color: AppStyles.primary)),
                            const SizedBox(height: 16),
                            _block('为什么要让孩子爱上篮球？', '少儿篮球不止是运动，更是成长的必修课。汗水浇灌的不止是健壮的体魄，更是克服困难的勇气。在团队协作中，培养少儿兴趣，不仅能锻炼身体，学会沟通，让孩子在笑声中收获自信与成长。'),
                            _block('少儿篮球兴趣培养小技巧', '1. 从基础玩入手：通过拍球的基础训练，让孩子在游戏中感受篮球的乐趣。\n2. 营造轻松的氛围：家长共同参与，与孩子一起享受运动时光。\n3. 尊重孩子的节奏：根据孩子的体能和兴趣，合理安排训练强度。\n4. 打造仪式感的收获：给孩子准备合身的球衣，完成训练后给予鼓励。'),
                            _block('小小年纪，逐梦球场', '愿每一个孩子，都能拿起篮球，释放天性，在运动中遇见更好的自己，让篮球的热情与快乐，点燃童年每一段美好时光！'),
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
