import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';

class ArticleDetailPage extends StatefulWidget {
  final int id;
  const ArticleDetailPage({super.key, required this.id});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.articleDetail(widget.id);
    setState(() {
      _detail = res['data'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?['title']?.toString() ?? '资讯详情';
    final cover = _detail?['cover']?.toString();
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
                            width: double.infinity,
                            color: const Color(0xFFE3F2FD),
                            child: cover != null && cover.isNotEmpty
                                ? AppNetworkImage(url: cover, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.article, size: 80, color: AppStyles.primary)),
                          ),
                          Positioned(
                            top: 40,
                            left: 12,
                            child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                                onPressed: () => Navigator.of(context).pop()),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
                                  child: const Text('资讯', style: TextStyle(color: AppStyles.primary)),
                                ),
                                const SizedBox(width: 12),
                                Text('${_detail?['author'] ?? ''}  ·  ${_detail?['viewCount'] ?? 0}次浏览',
                                    style: const TextStyle(color: AppStyles.textLight)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(_detail?['content']?.toString() ?? '暂无正文内容',
                                style: const TextStyle(fontSize: 15, color: AppStyles.textSub, height: 1.8)),
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
