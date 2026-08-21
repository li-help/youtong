import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_page_route.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'orders_page.dart';
import 'qrcode_page.dart';
import 'favorite_page.dart';
import 'address_list_page.dart';
import 'help_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
  }

  Future<void> _loadUser() async {
    try {
      final u = await ApiService.getUserInfo();
      setState(() => _user = u);
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final res = await ApiService.userStats();
      if (!mounted) return;
      setState(() => _stats = res['data'] is Map ? res['data'] as Map<String, dynamic> : null);
    } catch (_) {}
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(AppPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final nickname = _user?['nickname']?.toString() ?? '去登录';
    final username = _user?['username']?.toString() ?? '登录后体验更多功能';
    final loggedIn = _user != null;
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            GestureDetector(
              onTap: loggedIn ? null : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFECB3), AppStyles.primaryLight]),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: _user?['avatar'] != null && _user!['avatar'].toString().isNotEmpty
                            ? AppNetworkImage(url: _user!['avatar'].toString(), fit: BoxFit.cover)
                            : const FaIcon(FontAwesomeIcons.user, size: 36, color: AppStyles.textSub),
                      ),
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
                    FaIcon(loggedIn ? FontAwesomeIcons.cloud : FontAwesomeIcons.chevronRight, size: 28),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _user == null
                  ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage()))
                  : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const ProfilePage())),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: AppStyles.cardDecoration,
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.baby, color: AppStyles.primary, size: 32),
                    SizedBox(width: 12),
                    Expanded(child: Text('完善宝宝档案', style: TextStyle(fontWeight: FontWeight.bold))),
                    FaIcon(FontAwesomeIcons.chevronRight, color: AppStyles.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: AppStyles.cardDecoration,
              child: Row(
                children: [
                  _statItem('📦', _stats?['orderCount']?.toString() ?? '0', '我的订单', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const OrdersPage()))),
                  Container(width: 1, height: 36, color: const Color(0xFFF0F0F0)),
                  _statItem('❤️', _stats?['favoriteCount']?.toString() ?? '0', '我的收藏', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const FavoritePage()))),
                  Container(width: 1, height: 36, color: const Color(0xFFF0F0F0)),
                  _statItem('⭐', '100', '成长值', null),
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
                  const Row(children: [FaIcon(FontAwesomeIcons.solidStar, color: AppStyles.primary), SizedBox(width: 6), Text('我的服务', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  _menu('📦', '我的订单', '查看', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const OrdersPage()))),
                  _menu('📍', '收货地址', '管理', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const AddressListPage()))),
                  _menu('❤️', '我的收藏', '查看', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const FavoritePage()))),
                  _menu('📱', '我的二维码', '查看', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const QrcodePage()))),
                  _menu('📖', '使用说明', '查看', () => Navigator.of(context).push(AppPageRoute(builder: (_) => const HelpPage()))),
                  _menu('👤', '个人信息', '修改', _user == null ? () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(AppPageRoute(builder: (_) => const ProfilePage()))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (loggedIn)
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 16, color: Colors.black87))),
            Text(action, style: const TextStyle(color: AppStyles.primary, fontSize: 13)),
            const SizedBox(width: 4),
            const FaIcon(FontAwesomeIcons.chevronRight, color: AppStyles.textLight, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String icon, String value, String label, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppStyles.textLight)),
          ],
        ),
      ),
    );
  }
}
