import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import 'article_detail_page.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List<dynamic> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.listArticles(page: 1, pageSize: 20);
      final data = res['data'] ?? {};
      final list = data is List ? data : (data['list'] ?? []);
      setState(() {
        _articles = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: const Text('资讯'),
        backgroundColor: AppStyles.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
          : _articles.isEmpty
              ? const Center(child: Text('暂无资讯', style: TextStyle(color: AppStyles.textSub)))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppStyles.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _articles.length,
                    itemBuilder: (context, i) {
                      final item = _articles[i];
                      final cover = item['cover']?.toString();
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ArticleDetailPage(id: (item['id'] as num).toInt()))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppStyles.cardDecoration,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AppNetworkImage(
                                  url: cover,
                                  width: 100,
                                  height: 75,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title']?.toString() ?? '资讯',
                                        maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(item['summary']?.toString() ?? '',
                                        maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                    const SizedBox(height: 6),
                                    Text('${item['author'] ?? ''}  ·  ${item['createdAt'] ?? ''}',
                                        style: const TextStyle(fontSize: 12, color: AppStyles.textSub)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
