import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_error_retry.dart';

/// 文章详情
class ArticleViewPage extends StatefulWidget {
  final int id;
  const ArticleViewPage({super.key, required this.id});

  @override
  State<ArticleViewPage> createState() => _ArticleViewPageState();
}

class _ArticleViewPageState extends State<ArticleViewPage> {
  dynamic _article;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await ApiService.articleDetail(widget.id);
      setState(() {
        _article = res['data'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: const Text('文章详情'),
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error
              ? AppErrorRetry(onRetry: _load)
              : _article == null
                  ? const Center(child: Text('暂无内容', style: TextStyle(color: AppStyles.textLight)))
                  : _content(),
    );
  }

  Widget _content() {
    final cover = (_article['cover'] ?? _article['image'])?.toString();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cover != null && cover.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppNetworkImage(url: cover, width: double.infinity, height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            _article['title']?.toString() ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppStyles.textMain, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            '作者：${_article['author']?.toString() ?? '优童教研'} · ${_article['createdAt']?.toString() ?? ''}',
            style: const TextStyle(fontSize: 12, color: AppStyles.textLight),
          ),
          const SizedBox(height: 20),
          Text(
            _article['content']?.toString() ?? '暂无内容',
            style: const TextStyle(fontSize: 15, color: AppStyles.textMain, height: 1.9),
          ),
        ],
      ),
    );
  }
}
