import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_refresh_load.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;
  List<dynamic> _orders = [];
  bool _loading = true;
  bool _error = false;
  // 与后端 OrderController 状态对齐：0 待支付 / 1 已支付 / 2 已核销 / 3 已取消
  final _tabs = ['全部', '待支付', '已支付', '已核销', '已取消'];
  final _statusValues = [null, '0', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.listOrders(page: 1, pageSize: 20, status: _statusValues[_tab]);
      setState(() {
        _orders = res['data']?['list'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _orders = []; _loading = false; _error = true; });
    }
  }

  Future<void> _pay(dynamic o) async {
    final id = o['id'] is num ? (o['id'] as num).toInt() : int.tryParse(o['id']?.toString() ?? '') ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认支付'),
        content: const Text('当前为演示环境，点击确认将模拟支付成功。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('确认支付')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final res = await ApiService.payOrder(id);
      if (res['code'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('支付成功'), behavior: SnackBarBehavior.floating));
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg']?.toString() ?? '支付失败'), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('网络异常，支付失败'), behavior: SnackBarBehavior.floating));
    }
  }

  String _statusText(dynamic s) {
    switch (s?.toString()) {
      case '0': return '待支付';
      case '1': return '已支付';
      case '2': return '已核销';
      case '3': return '已取消';
      default: return '未知';
    }
  }

  Color _statusColor(dynamic s) {
    switch (s?.toString()) {
      case '0': return AppStyles.primary;
      case '1': return Colors.blue;
      case '2': return Colors.green;
      default: return AppStyles.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _tabs.asMap().entries.map((e) => GestureDetector(
                  onTap: () {
                    setState(() { _tab = e.key; _loading = true; });
                    _load();
                  },
                  child: Text(e.value,
                      style: TextStyle(
                        color: _tab == e.key ? AppStyles.primary : AppStyles.textSub,
                        fontWeight: _tab == e.key ? FontWeight.bold : FontWeight.normal,
                      )),
                )).toList(),
              ),
            ),
            Expanded(
              child: _loading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      itemBuilder: (_, __) => const SkeletonListTile(hasImage: false),
                    )
                  : _error
                      ? AppErrorRetry(onRetry: _load)
                      : _orders.isEmpty
                          ? AppEmptyState(
                              title: '暂无订单',
                              subtitle: '切换状态或下拉刷新看看',
                              onRefresh: _load,
                            )
                          : AppRefreshLoad(
                              onRefresh: _load,
                              enableLoadMore: false,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _orders.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, i) {
                                  final o = _orders[i];
                                  final status = o['status'];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: AppStyles.cardDecoration,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('订单号：${o['orderNo'] ?? o['id']}', style: const TextStyle(fontSize: 12, color: AppStyles.textLight)),
                                            Text(_statusText(status), style: TextStyle(color: _statusColor(status), fontSize: 13)),
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(color: AppStyles.orangeSoft, borderRadius: BorderRadius.circular(12)),
                                              child: const FaIcon(FontAwesomeIcons.graduationCap, color: Colors.white),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text(o['courseName']?.toString() ?? '课程报名', style: const TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('¥${o['amount'] ?? 0}', style: const TextStyle(color: AppStyles.price, fontWeight: FontWeight.bold)),
                                            if (status == '0')
                                              ElevatedButton(
                                                onPressed: () => _pay(o),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppStyles.primaryLight,
                                                  foregroundColor: AppStyles.primaryText,
                                                ),
                                                child: const Text('去支付'),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
