import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_page_route.dart';
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

  Future<void> _sendCode() async {
    final phone = _username.text.trim();
    if (phone.isEmpty) {
      _toast('请输入手机号');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _toast('请输入有效的手机号');
      return;
    }
    try {
      final res = await ApiService.sendCode(phone);
      if (res['code'] != 0) {
        _toast(res['msg']?.toString() ?? '验证码发送失败');
        return;
      }
      final demoCode = (res['data'] as Map<String, dynamic>?)?['code'];
      setState(() {
        _counting = true;
        _count = 60;
      });
      // 演示环境后端返回明文验证码，便于联调
      _toast(demoCode != null ? '验证码已发送（演示：$demoCode）' : '验证码已发送');
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
    } catch (e) {
      _toast('验证码发送失败：${e.toString()}');
    }
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

    setState(() => _loading = true);
    try {
      final res = await ApiService.register(phone, pwd, nickname: phone, code: code);
      if (res['code'] == 0) {
        if (!mounted) return;
        _toast('注册成功，请登录');
        Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const LoginPage()));
      } else {
        _toast(res['msg']?.toString() ?? '注册失败');
      }
    } catch (e) {
      _toast('网络异常：${e.toString()}');
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
      appBar: AppBar(
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
        title: const Text('注册账号', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppStyles.bg, AppStyles.amberSoft],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppStyles.primaryLight, width: 3),
                    ),
                    child: const FaIcon(FontAwesomeIcons.user, size: 64, color: AppStyles.textSub),
                  ),
                ),
                const SizedBox(height: 40),
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
                                foregroundColor: AppStyles.primaryText,
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
                            onPressed: () => Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const LoginPage())),
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
        ),
      ),
    );
  }

  InputDecoration _input(String hint) => AppStyles.inputDecoration(hintText: hint);
}
