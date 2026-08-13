import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'orders_page.dart';
import 'qrcode_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await ApiService.getUserInfo();
    setState(() => _user = u);
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final nickname = _user?['nickname']?.toString() ?? '去登录';
    final username = _user?['username']?.toString() ?? '登录后体验更多功能';
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFECB3), AppStyles.primaryLight]),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, size: 36, color: AppStyles.textSub),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB86E00))),
                        Text(username, style: const TextStyle(fontSize: 13, color: Color(0xFF9E7E3A))),
                      ],
                    ),
                  ),
                  const Icon(Icons.cloud, size: 28),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: AppStyles.cardDecoration,
              child: Row(
                children: [
                  const Icon(Icons.child_care, color: AppStyles.primary, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('完善宝宝档案', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Icon(Icons.chevron_right, color: AppStyles.textLight),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  const Row(children: [Icon(Icons.star, color: AppStyles.primary), SizedBox(width: 6), Text('我的服务', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  _menu('📦', '我的订单', '查看', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage()))),
                  _menu('📱', '我的二维码', '查看', _user == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrcodePage()))),
                  _menu('📖', '使用说明', '查看', () {}),
                  _menu('👤', '个人信息', '修改', _user == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _logout,
                  style: TextButton.styleFrom(foregroundColor: AppStyles.danger),
                  child: const Text('退出登录'),
                ),
              ),
            ),
            const Spacer(),
            const Text('🌟 陪伴宝宝快乐成长 🌟', style: TextStyle(color: AppStyles.textLight)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _menu(String icon, String name, String action, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action, style: const TextStyle(color: AppStyles.primary)),
          const Icon(Icons.chevron_right, color: AppStyles.textLight),
        ],
      ),
      onTap: onTap,
    );
  }
}
