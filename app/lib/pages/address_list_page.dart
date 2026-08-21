import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_retry.dart';
import '../widgets/app_page_route.dart';
import 'address_edit_page.dart';

/// 收货地址列表
class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<dynamic> _list = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await ApiService.listAddresses();
      final data = res['data'];
      setState(() {
        _list = data is List ? data : (data is Map ? (data['list'] is List ? data['list'] as List : []) : []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _setDefault(dynamic item) async {
    try {
      await ApiService.setDefaultAddress((item['id'] as num).toInt());
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设为默认地址')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败：${e.toString()}')));
      }
    }
  }

  Future<void> _delete(dynamic item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除地址'),
        content: const Text('确定要删除该地址吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除', style: TextStyle(color: AppStyles.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ApiService.deleteAddress((item['id'] as num).toInt());
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败：${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: const Text('收货地址'),
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? _skeleton()
          : _error
              ? AppErrorRetry(onRetry: _load)
              : _list.isEmpty
                  ? const AppEmptyState(title: '暂无收货地址', subtitle: '点击下方按钮新增地址')
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _list.length,
                        itemBuilder: (context, i) => _item(_list[i]),
                      ),
                    ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton.icon(
            onPressed: () async {
              await pushAppPage(context, page: const AddressEditPage());
              _load();
            },
            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
            label: const Text('新增收货地址'),
            style: AppStyles.primaryButton,
          ),
        ),
      ),
    );
  }

  Widget _item(dynamic item) {
    final isDefault = (item['isDefault'] ?? 0) == 1 || (item['isDefault'] ?? false) == true;
    final name = item['name']?.toString() ?? '';
    final phone = item['phone']?.toString() ?? '';
    final region = item['region']?.toString() ?? '';
    final detail = item['detail']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
              const SizedBox(width: 12),
              Text(phone, style: const TextStyle(fontSize: 14, color: AppStyles.textSub)),
              const Spacer(),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppStyles.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: const Text('默认', style: TextStyle(fontSize: 12, color: Color(0xFFB86E00))),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('$region $detail', style: const TextStyle(fontSize: 14, color: AppStyles.textSub, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: isDefault ? null : () => _setDefault(item),
                child: Row(
                  children: [
                    FaIcon(
                      isDefault ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circle,
                      size: 18,
                      color: isDefault ? AppStyles.primary : AppStyles.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(isDefault ? '默认地址' : '设为默认', style: TextStyle(fontSize: 13, color: isDefault ? AppStyles.primary : AppStyles.textSub)),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  await pushAppPage(context, page: AddressEditPage(address: item));
                  _load();
                },
                icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                label: const Text('编辑'),
                style: TextButton.styleFrom(foregroundColor: AppStyles.textSub, padding: EdgeInsets.zero),
              ),
              TextButton.icon(
                onPressed: () => _delete(item),
                icon: const FaIcon(FontAwesomeIcons.trash, size: 14),
                label: const Text('删除'),
                style: TextButton.styleFrom(foregroundColor: AppStyles.danger, padding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeleton(width: 80, height: 18, borderRadius: 4),
                SizedBox(width: 12),
                AppSkeleton(width: 110, height: 14, borderRadius: 4),
              ],
            ),
            SizedBox(height: 12),
            AppSkeleton(height: 14, borderRadius: 4),
            SizedBox(height: 6),
            AppSkeleton(width: 200, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
