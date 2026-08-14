import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  bool _loading = false;
  bool _counting = false;
  int _count = 60;

  void _sendCode() {
    if (_username.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入手机号')));
      return;
    }
    setState(() {
      _counting = true;
      _count = 60;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证码已发送：1234')));
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _count--);
      if (_count <= 0) {
        setState(() => _counting = false);
        return false;
      }
      return true;
    });
  }

  Future<void> _register() async {
    final phone = _username.text.trim();
    final pwd = _password.text;
    final confirm = _confirm.text;
    final code = _code.text.trim();

    if (phone.isEmpty) {
      _toast('请输入手机号');
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
    if (pwd != confirm) {
      _toast('两次密码不一致');
      return;
    }
    if (code.isEmpty) {
      _toast('请输入验证码');
      return;
    }
    if (code != '1234') {
      _toast('验证码错误');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.register(phone, pwd);
      if (res['code'] == 0) {
        if (!mounted) return;
        _toast('注册成功，请登录');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        _toast(res['msg']?.toString() ?? '注册失败');
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
            const Center(child: Text('一键授权', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
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
                  TextField(controller: _username, keyboardType: TextInputType.phone, decoration: _input('请输入手机号')),
                  const SizedBox(height: 16),
                  TextField(controller: _password, obscureText: true, decoration: _input('请输入密码')),
                  const SizedBox(height: 16),
                  TextField(controller: _confirm, obscureText: true, decoration: _input('请再次输入密码')),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: _code, keyboardType: TextInputType.number, decoration: _input('请输入验证码')),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _counting ? null : _sendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.bg,
                            foregroundColor: const Color(0xFFB86E00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_counting ? '$_count秒' : '获取验证码'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: AppStyles.primaryButton,
                      child: _loading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('立即注册'),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('已有账号？', style: TextStyle(color: AppStyles.textLight)),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())),
                        child: const Text('返回登录', style: TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
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
