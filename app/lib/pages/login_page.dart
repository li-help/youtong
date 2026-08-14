import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final phone = _username.text.trim();
    final pwd = _password.text;
    if (phone.isEmpty || pwd.isEmpty) {
      _toast('请填写手机号和密码');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _toast('请输入有效的手机号');
      return;
    }
    if (pwd.length < 6) {
      _toast('密码长度不能少于6位');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(phone, pwd);
      if (res['code'] == 0) {
        final data = res['data'] as Map<String, dynamic>;
        await ApiService.setToken(data['token'] as String);
        await ApiService.setUserInfo(data['user'] as Map<String, dynamic>);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
      } else {
        _toast(res['msg']?.toString() ?? '登录失败');
      }
    } catch (e) {
      _toast('网络异常，请检查网络后重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppStyles.bg, Color(0xFFFFECB3)],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Center(
              child: Text('一键授权', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppStyles.primaryLight, width: 3),
                ),
                child: const Icon(Icons.person_outline, size: 64, color: AppStyles.textSub),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  TextField(
                    controller: _username,
                    keyboardType: TextInputType.phone,
                    decoration: _input('请输入手机号'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: _input('请输入密码'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: AppStyles.primaryButton,
                      child: _loading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('登录'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('忘记密码', style: TextStyle(color: AppStyles.primary)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('切换一键登录方式', style: TextStyle(color: AppStyles.primary)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('还没有账号？', style: TextStyle(color: AppStyles.textLight)),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
                        child: const Text('立即注册', style: TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFFE082))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFFE082))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppStyles.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
