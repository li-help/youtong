import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;
  List<dynamic> _orders = [];
  bool _loading = true;
  // 与后端 OrderController 状态对齐：0 待支付 / 1 已支付 / 2 已核销 / 3 已取消
  final _tabs = ['全部', '待支付', '已支付', '已核销', '已取消'];
  final _statusValues = [null, '0', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.listOrders(page: 1, pageSize: 20, status: _statusValues[_tab]);
      setState(() {
        _orders = res['data']?['list'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _orders = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('订单加载失败，请稍后重试'), behavior: SnackBarBehavior.floating));
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
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('我的报名订单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _tabs.asMap().entries.map((e) => GestureDetector(
                  onTap: () {
                    setState(() { _tab = e.key; _loading = true; });
                    _load();
                  },
                  child: Text(e.value, style: TextStyle(color: _tab == e.key ? AppStyles.primary : AppStyles.textSub, fontWeight: _tab == e.key ? FontWeight.bold : FontWeight.normal)),
                )).toList(),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                  : _orders.isEmpty
                      ? const Center(child: Text('暂无订单', style: TextStyle(color: AppStyles.textSub)))
                      : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
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
                                    decoration: BoxDecoration(color: const Color(0xFFFFCC80), borderRadius: BorderRadius.circular(12)),
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
                                  Text('¥${o['amount'] ?? 0}', style: const TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold)),
                                  if (status == '0') ElevatedButton(onPressed: () => _pay(o), style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryLight, foregroundColor: const Color(0xFFB86E00)), child: const Text('去支付')),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
