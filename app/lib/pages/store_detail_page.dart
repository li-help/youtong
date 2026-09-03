import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';
import 'store_chat_page.dart';

class StoreDetailPage extends StatefulWidget {
  final int id;
  const StoreDetailPage({super.key, required this.id});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  Map<String, dynamic>? _store;
  List<dynamic> _services = [];
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
      final results = await Future.wait([
        ApiService.request('GET', '/store/${widget.id}'),
        ApiService.listServices(page: 1, pageSize: 50),
      ]);
      final store = results[0]['data'];
      final allServices = results[1]['data']?['list'] ?? [];
      setState(() {
        _store = store is Map<String, dynamic> ? store : null;
        final own = _store?['services'];
        _services = own is List ? own : allServices;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cover = _store == null
        ? null
        : (_store!['cover'] ?? _store!['logo'] ?? _store!['image'])?.toString();
    return Scaffold(
      body: _loading
          ? _skeletonView()
          : _error
              ? SafeArea(child: AppErrorRetry(onRetry: _load))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: cover != null && cover.isNotEmpty
                            ? AppNetworkImage(url: cover, fit: BoxFit.cover, width: double.infinity)
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [AppStyles.primary, AppStyles.primaryLight]),
                                ),
                              ),
                      ),
                      leading: const BackButton(color: Colors.white),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_store?['name']?.toString() ?? '门店详情',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const FaIcon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${_store?['score'] ?? 4.8}', style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.locationDot, size: 16, color: AppStyles.textSub),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(_store?['address']?.toString() ?? '暂无地址',
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_store?['phone'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const FaIcon(FontAwesomeIcons.phone, size: 16, color: AppStyles.textSub),
                                  const SizedBox(width: 4),
                                  Text(_store!['phone'].toString(), style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            // 在线咨询门店客服
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(23),
                                  border: Border.all(color: AppStyles.primary.withOpacity(0.4)),
                                  color: Colors.white,
                                ),
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => StoreChatPage(
                                        storeId: int.tryParse(_store?['id']?.toString() ?? '') ?? 0,
                                        storeName: _store?['name']?.toString(),
                                      ),
                                    ));
                                  },
                                  icon: const Text('💬', style: TextStyle(fontSize: 16)),
                                  label: const Text('在线咨询门店客服',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppStyles.primary)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('门店服务', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
                            const SizedBox(height: 12),
                            ..._services.map((s) {
                              final sv = s as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: AppStyles.cardDecoration,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sv['name']?.toString() ?? '服务',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppStyles.textMain)),
                                          const SizedBox(height: 4),
                                          if (sv['description'] != null)
                                            Text(sv['description'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppStyles.textSub)),
                                        ],
                                      ),
                                    ),
                                    if (sv['price'] != null)
                                      Text('¥${sv['price']}', style: const TextStyle(fontSize: 16, color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                            if (_services.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: Text('暂无服务', style: TextStyle(color: AppStyles.textLight))),
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
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(background: AppSkeleton(height: 220, borderRadius: 0)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 180, height: 24, borderRadius: 4),
                const SizedBox(height: 16),
                const AppSkeleton(width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                const AppSkeleton(width: 100, height: 18, borderRadius: 4),
                const SizedBox(height: 12),
                ...List.generate(3, (_) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: AppStyles.cardDecoration,
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton(width: 120, height: 16, borderRadius: 4),
                            SizedBox(height: 8),
                            AppSkeleton(height: 14, borderRadius: 4),
                          ],
                        ),
                      ),
                      AppSkeleton(width: 40, height: 18, borderRadius: 4),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
