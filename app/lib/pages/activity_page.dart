import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_scroll_top.dart';
import '../widgets/app_page_route.dart';
import '../widgets/app_page_header.dart';
import 'activity_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<dynamic> _activities = [];
  bool _loading = true;
  bool _error = false;
  int _page = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
      _page = 1;
    });
    try {
      final res = await ApiService.listActivities(page: 1, pageSize: 20);
      setState(() {
        _activities = res['data']?['list'] ?? [];
        _hasMore = (res['data']?['total'] ?? 0) > _activities.length;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;
    try {
      final next = _page + 1;
      final res = await ApiService.listActivities(page: next, pageSize: 20);
      final list = res['data']?['list'] ?? [];
      setState(() {
        _activities.addAll(list);
        _page = next;
        _hasMore = list.length >= 20;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: _loading
            ? Column(
                children: [
                  const AppPageHeader(title: '活动'),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      itemBuilder: (_, __) => const SkeletonListTile(),
                    ),
                  ),
                ],
              )
            : _error
                ? Column(
                    children: [
                      const AppPageHeader(title: '活动'),
                      Expanded(child: AppErrorRetry(onRetry: _load)),
                    ],
                  )
                : _activities.isEmpty
                    ? Column(
                        children: [
                          const AppPageHeader(title: '活动'),
                          Expanded(
                            child: AppEmptyState(
                              title: '暂无活动',
                              subtitle: '下拉刷新看看最新活动',
                              onRefresh: _load,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const AppPageHeader(title: '活动'),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n is ScrollUpdateNotification) {
                                      final m = n.metrics;
                                      if (m.pixels >= m.maxScrollExtent - 80)
                                        _loadMore();
                                    }
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    onRefresh: _load,
                                    color: AppStyles.primary,
                                    backgroundColor: Colors.white,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _activities.length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, i) =>
                                          GestureDetector(
                                        onTap: () => pushAppPage(context,
                                            page: ActivityDetailPage(
                                                id: (_activities[i]['id']
                                                        as num)
                                                    .toInt())),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: AppStyles.cardDecoration,
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: SizedBox(
                                                  width: 100,
                                                  height: 75,
                                                  child: AppNetworkImage(
                                                    url: _activities[i]['cover']
                                                        ?.toString(),
                                                    width: 100,
                                                    height: 75,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        _activities[i]['title']
                                                                ?.toString() ??
                                                            '活动',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                        _activities[i]
                                                                    ['summary']
                                                                ?.toString() ??
                                                            '',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: AppStyles
                                                                .textSub)),
                                                    Text(
                                                        '${_activities[i]['viewCount'] ?? 0}次浏览',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppStyles
                                                                .primary)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AppScrollTopButton(
                                    controller: _scrollController),
                              ],
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
