import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
import 'orders_page.dart';

class ActivityDetailPage extends StatefulWidget {
  final int id;
  const ActivityDetailPage({super.key, required this.id});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.activityDetail(widget.id);
      setState(() {
        _detail = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  Future<void> _book() async {
    try {
      await ApiService.createOrder({
        'type': 'activity',
        'targetId': widget.id,
        'title': _detail?['title'] ?? '',
        'price': _detail?['price'] ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('报名成功，可在「我的订单」查看')));
        pushAppPage(context, page: const OrdersPage());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('报名失败：${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?['title']?.toString() ?? '活动详情';
    final views = _detail?['viewCount'] ?? 0;
    final price = _detail?['price'];
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? _skeletonView()
          : _error
              ? SafeArea(child: AppErrorRetry(onRetry: _load))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 96),
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
                                    : const Center(child: FaIcon(FontAwesomeIcons.cakeCandles, size: 80, color: Colors.white)),
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
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        color: AppStyles.bg,
                                        child: const Text('活动', style: TextStyle(color: AppStyles.primary)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('$views次浏览', style: const TextStyle(color: AppStyles.textLight)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(_detail?['content']?.toString() ?? _detail?['description']?.toString() ?? '暂无详情内容', style: const TextStyle(fontSize: 15, color: AppStyles.textSub, height: 1.8)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))]),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('活动价', style: TextStyle(fontSize: 12, color: AppStyles.textLight)),
                                Text(price != null ? '¥$price' : '免费', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppStyles.primary)),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _book,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text('立即报名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                const AppSkeleton(width: 180, height: 24, borderRadius: 4),
                const SizedBox(height: 16),
                const AppSkeleton(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(width: 200, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
