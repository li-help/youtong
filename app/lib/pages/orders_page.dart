import 'package:flutter/material.dart';
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
  // 与后端 OrderController 状态枚举对齐：pending/paid/completed/cancelled
  final _tabs = ['全部', '待支付', '已支付', '已核销', '已取消'];
  final _statusValues = [null, 'pending', 'paid', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.listOrders(page: 1, pageSize: 20, status: _statusValues[_tab]);
    setState(() {
      _orders = res['data']?['list'] ?? [];
      _loading = false;
    });
  }

  String _statusText(dynamic s) {
    switch (s?.toString()) {
      case 'pending': return '待支付';
      case 'paid': return '已支付';
      case 'completed': return '已核销';
      case 'cancelled': return '已取消';
      default: return '未知';
    }
  }

  Color _statusColor(dynamic s) {
    switch (s?.toString()) {
      case 'pending': return AppStyles.primary;
      case 'paid': return Colors.blue;
      case 'completed': return Colors.green;
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
                                    child: const Icon(Icons.school, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(o['course_name']?.toString() ?? '课程报名', style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('¥${o['amount'] ?? 0}', style: const TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold)),
                                  if (status == 'pending') ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryLight, foregroundColor: const Color(0xFFB86E00)), child: const Text('去支付')),
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
