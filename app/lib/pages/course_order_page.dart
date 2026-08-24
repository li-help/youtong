import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
import 'main_page.dart';

class CourseOrderPage extends StatefulWidget {
  final int id;
  const CourseOrderPage({super.key, required this.id});

  @override
  State<CourseOrderPage> createState() => _CourseOrderPageState();
}

class _CourseOrderPageState extends State<CourseOrderPage> {
  Map<String, dynamic>? _course;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _remark = TextEditingController();
  String? _age;
  final _ageOptions = ['0-1岁', '1-3岁', '3-6岁', '6岁以上'];
  bool _loading = true;
  bool _error = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.courseDetail(widget.id);
      setState(() {
        _course = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写报名信息')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final res = await ApiService.createOrder({
        'courseId': widget.id,
        'courseName': _course?['title'],
        'price': _course?['price'],
        'contactName': _name.text,
        'contactPhone': _phone.text,
        'ageRange': _age,
        'remark': _remark.text,
      });
      if (res['code'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('报名成功')));
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              AppPageRoute(builder: (_) => const MainPage()),
              (_) => false,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'] ?? '报名失败')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _course?['price'] ?? 0;
    final title = _course?['title']?.toString() ?? '课程';
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? _skeletonView()
          : _error
              ? SafeArea(child: AppErrorRetry(onRetry: _load))
              : SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: AppBackButton(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: AppStyles.cardDecoration,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(color: AppStyles.orangeSoft, borderRadius: BorderRadius.circular(12)),
                                      child: const FaIcon(FontAwesomeIcons.graduationCap, color: Colors.white),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text('¥$price', style: const TextStyle(fontSize: 18, color: AppStyles.price, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: AppStyles.cardDecoration,
                                child: Column(
                                  children: [
                                    _field('报名人姓名', _name, '请输入姓名'),
                                    _field('联系电话', _phone, '请输入手机号', TextInputType.phone),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 100,
                                            child: Text('宝宝年龄', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          Expanded(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Text('请选择年龄'),
                                              value: _age,
                                              items: _ageOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                                              onChanged: (v) => setState(() => _age = v),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _field('备注', _remark, '选填'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const Text('合计：', style: TextStyle(fontSize: 16)),
                            Text('¥$price', style: const TextStyle(fontSize: 22, color: AppStyles.price, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submit,
                                style: AppStyles.primaryButton,
                                child: const Text('提交报名'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _skeletonView() {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AppSkeleton(height: 24, borderRadius: 4),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: const Row(
                children: [
                  AppSkeleton(width: 80, height: 80, borderRadius: 12),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 120, height: 16, borderRadius: 4),
                      SizedBox(height: 8),
                      AppSkeleton(width: 60, height: 18, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSkeleton(height: 50, borderRadius: 8),
                    const SizedBox(height: 12),
                    const AppSkeleton(height: 50, borderRadius: 8),
                    const SizedBox(height: 12),
                    const AppSkeleton(height: 50, borderRadius: 8),
                    const SizedBox(height: 12),
                    const AppSkeleton(height: 80, borderRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint, [TextInputType? type]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: type,
              decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ),
        ],
      ),
    );
  }
}
