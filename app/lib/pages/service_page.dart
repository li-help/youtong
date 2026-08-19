import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';

class ServicePage extends StatefulWidget {
  final String title;
  const ServicePage({super.key, this.title = '优享服务'});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
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
      final res = await ApiService.listServices(page: 1, pageSize: 50);
      setState(() {
        _services = res['data']?['list'] ?? [];
        _loading = false;
        _error = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  void _book(BuildContext context, Map<String, dynamic> s) {
    final phone = s['phone']?.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s['name']?.toString() ?? '服务预约'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s['description']?.toString().isNotEmpty == true)
              Text(s['description'].toString(), style: const TextStyle(fontSize: 14, height: 1.6)),
            if (s['price'] != null) ...[
              const SizedBox(height: 10),
              Text('价格：¥${s['price']}', style: const TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
            ],
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('联系电话：$phone'),
            ],
            const SizedBox(height: 10),
            const Text('预约请致电门店，我们会为您安排体验时间。', style: TextStyle(fontSize: 12, color: AppStyles.textSub)),
          ],
        ),
        actions: [
          if (phone != null && phone.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: phone));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('电话已复制到剪贴板'), behavior: SnackBarBehavior.floating));
              },
              child: const Text('复制电话'),
            ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('知道了')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: AppStyles.textMain, elevation: 0),
      body: _loading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => const SkeletonListTile(),
            )
          : _error
              ? AppErrorRetry(onRetry: _load)
              : _services.isEmpty
                  ? AppEmptyState(
                      title: '暂无服务',
                      subtitle: '下拉刷新或稍后重试',
                      onRefresh: _load,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppStyles.primary,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _services.length,
                        itemBuilder: (ctx, i) {
                  final s = _services[i] as Map<String, dynamic>;
                  final cover = (s['cover'] ?? s['image'])?.toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                          child: AppNetworkImage(url: cover, width: 110, height: 110, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name']?.toString() ?? '服务',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
                                const SizedBox(height: 6),
                                Text(s['description']?.toString() ?? '',
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (s['price'] != null)
                                      Text('¥${s['price']}', style: const TextStyle(fontSize: 17, color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppStyles.primary, borderRadius: BorderRadius.circular(20)),
                                      child: InkWell(
                                        onTap: () => _book(context, s),
                                        child: const Text('预约', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
