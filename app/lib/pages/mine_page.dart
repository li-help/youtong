import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
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
    final loggedIn = _user != null;
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            GestureDetector(
              onTap: loggedIn ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())),
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
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: _user?['avatar'] != null && _user!['avatar'].toString().isNotEmpty
                            ? AppNetworkImage(url: _user!['avatar'].toString(), fit: BoxFit.cover)
                            : const ColoredBox(
                                color: Colors.white,
                                child: FaIcon(FontAwesomeIcons.user, size: 36, color: AppStyles.textSub),
                              ),
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
                    Icon(loggedIn ? FontAwesomeIcons.cloud : FontAwesomeIcons.chevronRight, size: 28),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _user == null
                  ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()))
                  : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
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
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  const Row(children: [FaIcon(FontAwesomeIcons.solidStar, color: AppStyles.primary), SizedBox(width: 6), Text('我的服务', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  _menu('📦', '我的订单', '查看', _user == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage()))),
                  _menu('📱', '我的二维码', '查看', _user == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrcodePage()))),
                  _menu('📖', '使用说明', '查看', () => _showHelp(context)),
                  _menu('👤', '个人信息', '修改', _user == null ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())) : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()))),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action, style: const TextStyle(color: AppStyles.primary)),
          const FaIcon(FontAwesomeIcons.chevronRight, color: AppStyles.textLight),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Text(
            '1. 首页可查看精选课程、活动、视频与资讯，下滑可刷新。\n\n'
            '2. 注册登录后可报名课程、参与活动、查看订单。\n\n'
            '3. 智能推荐：填写宝宝年龄、身高体重后，系统将智能匹配适合的课程。\n\n'
            '4. 我的订单中可查看报名记录，到店后出示二维码即可核销。\n\n'
            '5. 如遇问题，请联系门店客服或前往门店详情页拨打电话。',
            style: TextStyle(fontSize: 14, height: 1.7),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('知道了')),
        ],
      ),
    );
  }
}
