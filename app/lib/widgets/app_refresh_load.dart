import 'package:flutter/material.dart';
import 'app_styles.dart';

/// 下拉刷新 + 上拉加载更多封装
class AppRefreshLoad extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final ScrollController? controller;
  final Widget child;
  final bool enableLoadMore;
  final EdgeInsetsGeometry? padding;

  const AppRefreshLoad({
    super.key,
    required this.onRefresh,
    this.onLoadMore,
    this.controller,
    required this.child,
    this.enableLoadMore = true,
    this.padding,
  });

  @override
  State<AppRefreshLoad> createState() => _AppRefreshLoadState();
}

class _AppRefreshLoadState extends State<AppRefreshLoad> {
  bool _loadingMore = false;

  Future<void> _onRefresh() async {
    await widget.onRefresh();
  }

  void _onScroll(ScrollNotification notification) {
    if (!widget.enableLoadMore || widget.onLoadMore == null) return;
    if (_loadingMore) return;
    final metrics = notification.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - 80) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppStyles.primary,
      backgroundColor: Colors.white,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) _onScroll(n);
          return false;
        },
        child: SingleChildScrollView(
          controller: widget.controller,
          padding: widget.padding,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.child,
              if (_loadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppStyles.primary))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
