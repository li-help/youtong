import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_scroll_top.dart';
import '../widgets/app_search_history.dart';
import '../widgets/app_page_route.dart';
import '../widgets/app_page_header.dart';
import 'course_detail_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<dynamic> _courses = [];
  List<dynamic> _categories = [];
  int? _activeCat;
  String _keyword = '';
  bool _loading = true;
  bool _error = false;
  int _page = 1;
  bool _hasMore = true;
  bool _showHistory = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  // 顶部分类宫格图标：按分类名匹配，未命中时回退星形
  static const Map<String, FaIconData> _catIcons = {
    '全部': FontAwesomeIcons.borderAll,
    '兴趣培养': FontAwesomeIcons.palette,
    '学科辅导': FontAwesomeIcons.bookOpen,
    '绘画': FontAwesomeIcons.paintbrush,
    '创意绘画': FontAwesomeIcons.paintbrush,
    '音乐': FontAwesomeIcons.music,
    '音乐启蒙': FontAwesomeIcons.music,
    '音乐律动': FontAwesomeIcons.music,
    '数学': FontAwesomeIcons.calculator,
    '英语': FontAwesomeIcons.comments,
    '语言表达': FontAwesomeIcons.comments,
    '绘本阅读': FontAwesomeIcons.bookOpenReader,
    '益智游戏': FontAwesomeIcons.puzzlePiece,
    '科学启蒙': FontAwesomeIcons.flask,
    '艺术创作': FontAwesomeIcons.palette,
    '运动健康': FontAwesomeIcons.futbol,
    '视频课程': FontAwesomeIcons.video,
  };

  static const FaIconData _fallbackCatIcon = FontAwesomeIcons.star;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
      _page = 1;
    });
    try {
      final results = await Future.wait([
        ApiService.listCourses(
            page: 1, pageSize: 20, keyword: _keyword, categoryId: _activeCat),
        ApiService.listCategories(page: 1, pageSize: 50),
      ]);
      setState(() {
        _courses = results[0]['data']?['list'] ?? [];
        _hasMore = (results[0]['data']?['total'] ?? 0) > _courses.length;
        _categories = results[1]['data']?['list'] ?? [];
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
      final res = await ApiService.listCourses(
        page: next,
        pageSize: 20,
        keyword: _keyword,
        categoryId: _activeCat,
      );
      final list = res['data']?['list'] ?? [];
      setState(() {
        _courses.addAll(list);
        _page = next;
        _hasMore = list.length >= 20;
      });
    } catch (_) {}
  }

  Future<void> _search(String keyword) async {
    _searchController.text = keyword;
    _searchFocus.unfocus();
    setState(() {
      _keyword = keyword;
      _showHistory = false;
    });
    await AppSearchHistory.save(keyword);
    await _load();
  }

  Future<void> _clearSearch() async {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _showHistory = true;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: '课程'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (v) {
                          setState(() {
                            _keyword = v;
                            _showHistory = v.isEmpty;
                          });
                        },
                        onSubmitted: (v) => _search(v),
                        onTap: () =>
                            setState(() => _showHistory = _keyword.isEmpty),
                        decoration: InputDecoration(
                          hintText: '课程名称',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          suffixIcon: _keyword.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 20, color: AppStyles.textSub),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _search(_keyword),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppStyles.primaryLight,
                          borderRadius: BorderRadius.circular(24)),
                      child: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            if (_showHistory && _keyword.isEmpty)
              AppSearchHistory(
                onTap: (k) => _search(k),
                onChanged: () => setState(() {}),
              ),
            SizedBox(
              height: _categories.isEmpty ? 0 : 96,
              child: _loading
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: 6,
                      itemBuilder: (_, __) => Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppSkeleton(
                                width: 64, height: 64, borderRadius: 16),
                            SizedBox(height: 8),
                            AppSkeleton(width: 50, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          final all = _activeCat == null;
                          return _catChip(
                              '全部',
                              all,
                              () => setState(() {
                                    _activeCat = null;
                                    _load();
                                  }));
                        }
                        final c = _categories[i - 1];
                        final active = _activeCat == c['id'];
                        return _catChip(
                            c['name']?.toString() ?? '分类',
                            active,
                            () => setState(() {
                                  _activeCat = c['id'] as int?;
                                  _load();
                                }));
                      },
                    ),
            ),
            Expanded(
              child: _loading
                  ? _skeletonGrid()
                  : _error
                      ? AppErrorRetry(onRetry: _load)
                      : _courses.isEmpty
                          ? AppEmptyState(
                              title: '暂无课程',
                              subtitle: '换个关键词或分类试试看',
                              onRefresh: _load,
                            )
                          : Stack(
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
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: _courses.length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, i) =>
                                          GestureDetector(
                                        onTap: () => pushAppPage(context,
                                            page: CourseDetailPage(
                                                id: (_courses[i]['id'] as num)
                                                    .toInt())),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: AppStyles.cardDecoration,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: AppNetworkImage(
                                                        url: _courses[i]
                                                                ['cover']
                                                            ?.toString(),
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 4,
                                                      top: 4,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        color: AppStyles.bg,
                                                        child: const Text('自营',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: AppStyles
                                                                    .primary)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                  _courses[i]['title']
                                                          ?.toString() ??
                                                      '课程',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 13)),
                                              Text(
                                                  '¥${_courses[i]['price'] ?? 0}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppStyles.primary)),
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

  Widget _skeletonGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (_, __) => const SkeletonGridCard(),
      ),
    );
  }

  Widget _catChip(String name, bool active, VoidCallback onTap) {
    final icon = _catIcons[name] ?? _fallbackCatIcon;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppStyles.primary : AppStyles.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: FaIcon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            Text(name,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
