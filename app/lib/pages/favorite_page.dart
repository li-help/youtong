import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
import '../widgets/app_page_header.dart';
import 'course_detail_page.dart';
import 'activity_detail_page.dart';
import 'video_page.dart';

/// 我的收藏：全部 / 课程 / 活动 / 视频
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabs = ['全部', '课程', '活动', '视频'];
  final List<String?> _types = [null, 'course', 'activity', 'video'];
  final List<List<dynamic>> _lists = [[], [], [], []];
  final List<bool> _loading = [true, true, true, true];
  final List<bool> _error = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final i = _tabController.index;
      if (_lists[i].isEmpty && !_loading[i]) _load(i);
    });
    for (var i = 0; i < _tabs.length; i++) {
      _load(i);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load(int index) async {
    setState(() {
      _loading[index] = true;
      _error[index] = false;
    });
    try {
      final res = await ApiService.listFavorites(targetType: _types[index]);
      final data = res['data'];
      final list = data is List
          ? data
          : (data is Map
              ? (data['list'] is List ? data['list'] as List : [])
              : []);
      setState(() {
        _lists[index] = list;
        _loading[index] = false;
      });
    } catch (e) {
      setState(() {
        _loading[index] = false;
        _error[index] = true;
      });
    }
  }

  Future<void> _remove(int index, dynamic item) async {
    try {
      await ApiService.removeFavorite({
        'targetType': item['targetType'],
        'targetId': item['targetId'],
      });
      setState(() => _lists[index].remove(item));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已取消收藏')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('操作失败：${e.toString()}')));
      }
    }
  }

  void _open(dynamic item) {
    final id = item['targetId'];
    if (id == null) return;
    final i = (id is num) ? id.toInt() : int.tryParse(id.toString()) ?? 0;
    switch (item['targetType']) {
      case 'course':
        pushAppPage(context, page: CourseDetailPage(id: i));
        break;
      case 'activity':
        pushAppPage(context, page: ActivityDetailPage(id: i));
        break;
      case 'video':
        pushAppPage(context, page: VideoPage(id: i));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: '我的收藏', showBack: true),
            Container(
              color: AppStyles.bg,
              child: TabBar(
                controller: _tabController,
                labelColor: AppStyles.primary,
                unselectedLabelColor: AppStyles.textSub,
                indicatorColor: AppStyles.primary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_tabs.length, (i) => _buildTab(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    if (_loading[index]) return _skeleton();
    if (_error[index]) return AppErrorRetry(onRetry: () => _load(index));
    final list = _lists[index];
    if (list.isEmpty)
      return const AppEmptyState(title: '暂无收藏', subtitle: '去逛逛喜欢的课程和活动吧');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppStyles.cardDecoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _open(item),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppNetworkImage(
                      url: item['cover']?.toString(),
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']?.toString() ?? '未命名',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppStyles.textMain),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppStyles.bg,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                  _typeName(item['targetType']?.toString()),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppStyles.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _remove(index, item),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const FaIcon(FontAwesomeIcons.solidHeart,
                          size: 22, color: AppStyles.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _typeName(String? type) {
    switch (type) {
      case 'course':
        return '课程';
      case 'activity':
        return '活动';
      case 'video':
        return '视频';
      default:
        return '内容';
    }
  }

  Widget _skeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: AppStyles.cardDecoration,
        child: const Row(
          children: [
            AppSkeleton(width: 84, height: 84, borderRadius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 160, height: 16, borderRadius: 4),
                  SizedBox(height: 12),
                  AppSkeleton(width: 48, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
