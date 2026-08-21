import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
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
  bool _error = false;
  bool _fav = false;
  bool _favBusy = false;

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
        _detail = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
      _loadFavStatus();
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  Future<void> _loadFavStatus() async {
    try {
      final res = await ApiService.favoriteStatus('course', widget.id);
      final data = res['data'];
      final fav = data is bool ? data : (data is Map ? (data['favorited'] == true || data['favorite'] == true) : false);
      if (mounted) setState(() => _fav = fav);
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (_favBusy || _detail == null) return;
    setState(() => _favBusy = true);
    try {
      final payload = {
        'targetType': 'course',
        'targetId': widget.id,
        'title': _detail?['title']?.toString() ?? '',
        'cover': _detail?['cover']?.toString() ?? '',
      };
      if (_fav) {
        await ApiService.removeFavorite(payload);
      } else {
        await ApiService.addFavorite(payload);
      }
      if (!mounted) return;
      setState(() {
        _fav = !_fav;
        _favBusy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_fav ? '收藏成功' : '已取消收藏')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _favBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败：${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _detail?['price'] ?? 0;
    final title = _detail?['title']?.toString() ?? '课程详情';
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? _skeletonView()
          : _error
              ? SafeArea(child: AppErrorRetry(onRetry: _load))
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
                                width: double.infinity,
                                color: const Color(0xFFFFCC80),
                                child: _detail?['cover'] != null
                                    ? AppNetworkImage(
                                        url: _detail!['cover']?.toString(),
                                        width: double.infinity,
                                        height: 260,
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(child: FaIcon(FontAwesomeIcons.graduationCap, size: 80, color: Colors.white)),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top + 12,
                                left: 16,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(22)),
                                    child: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.black87),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                top: MediaQuery.of(context).padding.top + 12,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(16)),
                                      child: Text(_detail?['categoryName']?.toString() ?? _detail?['category']?.toString() ?? '热门课程', style: const TextStyle(color: AppStyles.primary, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _favBusy ? null : _toggleFav,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(22)),
                                        child: FaIcon(
                                          _fav ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                                          size: 22,
                                          color: _fav ? const Color(0xFFFFB300) : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 16,
                                top: 170,
                                child: Text('¥$price', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6F00))),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
                                onPressed: () => pushAppPage(context, page: CourseOrderPage(id: widget.id)),
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

  Widget _skeletonView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 260, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 200, height: 24, borderRadius: 4),
                const SizedBox(height: 12),
                const AppSkeleton(width: 140, height: 16, borderRadius: 4),
                const SizedBox(height: 32),
                const AppSkeleton(width: 100, height: 22, borderRadius: 4),
                const SizedBox(height: 10),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(width: 220, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                const AppSkeleton(width: 100, height: 22, borderRadius: 4),
                const SizedBox(height: 10),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(width: 260, height: 14, borderRadius: 4),
              ],
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
