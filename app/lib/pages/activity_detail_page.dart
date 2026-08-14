import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

class ActivityDetailPage extends StatefulWidget {
  final int id;
  const ActivityDetailPage({super.key, required this.id});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.activityDetail(widget.id);
    setState(() {
      _detail = res['data'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?['title']?.toString() ?? '活动详情';
    final views = _detail?['viewCount'] ?? 0;
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 260,
                            color: const Color(0xFFFFCC80),
                            child: const Center(child: Icon(Icons.celebration, size: 80, color: Colors.white)),
                          ),
                          Positioned(
                            top: 40,
                            left: 12,
                            child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
