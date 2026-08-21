import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
import 'article_view_page.dart';

/// 学习天地：文章列表（按分类）
class ArticleListPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  const ArticleListPage({super.key, this.categoryId, this.categoryName});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final List<dynamic> _list = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _loading = true;
  bool _error = false;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    setState(() {
      _loading = _list.isEmpty;
      _error = false;
    });
    try {
      final res = await ApiService.listArticles(
        page: _page,
        pageSize: 20,
        categoryId: widget.categoryId,
      );
      final data = res['data'];
      final rows = data is Map ? (data['list'] is List ? data['list'] as List : []) : (data is List ? data : []);
      setState(() {
        if (refresh) _list.clear();
        _list.addAll(rows);
        _hasMore = rows.length >= 20;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _list.isEmpty;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    _page++;
    try {
      final res = await ApiService.listArticles(
        page: _page,
        pageSize: 20,
        categoryId: widget.categoryId,
      );
      final data = res['data'];
      final rows = data is Map ? (data['list'] is List ? data['list'] as List : []) : (data is List ? data : []);
      setState(() {
        _list.addAll(rows);
        _hasMore = rows.length >= 20;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: Text(widget.categoryName ?? '学习天地'),
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? _skeleton()
          : _error
              ? AppErrorRetry(onRetry: () => _load(refresh: true))
              : _list.isEmpty
                  ? const AppEmptyState(title: '暂无内容', subtitle: '该分类下还没有发布文章')
                  : RefreshIndicator(
                      onRefresh: () => _load(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _list.length + 1,
                        itemBuilder: (context, i) {
                          if (i == _list.length) {
                            return _loadingMore
                                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                                : const SizedBox(height: 16);
                          }
                          return _card(_list[i]);
                        },
                      ),
                    ),
    );
  }

  Widget _card(dynamic a) {
    final cover = (a['cover'] ?? a['image'] ?? a['logo'])?.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppStyles.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => pushAppPage(context, page: ArticleViewPage(id: (a['id'] as num).toInt())),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppNetworkImage(
                  url: cover,
                  width: 90,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['title']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppStyles.textMain),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '作者：${a['author']?.toString() ?? '优童教研'}',
                      style: const TextStyle(fontSize: 12, color: AppStyles.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: AppStyles.cardDecoration,
        child: const Row(
          children: [
            AppSkeleton(width: 90, height: 65, borderRadius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(height: 16, borderRadius: 4),
                  SizedBox(height: 10),
                  AppSkeleton(width: 120, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
