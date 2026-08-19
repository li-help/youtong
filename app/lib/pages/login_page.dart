import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_page_route.dart';
import 'main_page.dart';
import 'register_page.dart';
import 'reset_pwd_page.dart';

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
        final data = res['data'] as Map<String, dynamic>?;
        final token = data?['token']?.toString();
        final user = data?['user'] as Map<String, dynamic>?;
        if (token == null || token.isEmpty || user == null) {
          _toast('登录接口返回数据异常');
          return;
        }
        await ApiService.setToken(token);
        await ApiService.setUserInfo(user);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const MainPage()));
      } else {
        _toast(res['msg']?.toString() ?? '登录失败');
      }
    } catch (e) {
      _toast('网络异常：${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 一键登录（测试体验用）：自动用固定账号登录，若账号未注册则自动获取验证码并注册后再登录。
  Future<void> _oneKeyLogin() async {
    const phone = '13800000000';
    const pwd = '123456';
    setState(() => _loading = true);
    try {
      // 1. 尝试直接登录
      final loginRes = await ApiService.login(phone, pwd);
      if (loginRes['code'] == 0) {
        final data = loginRes['data'] as Map<String, dynamic>?;
        final token = data?['token']?.toString();
        final user = data?['user'] as Map<String, dynamic>?;
        if (token == null || token.isEmpty || user == null) {
          _toast('一键登录返回数据异常');
          return;
        }
        await ApiService.setToken(token);
        await ApiService.setUserInfo(user);
        if (!mounted) return;
        _toast('一键登录成功');
        Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const MainPage()));
        return;
      }

      // 2. 登录失败，尝试自动注册：先获取演示验证码
      final sendRes = await ApiService.sendCode(phone);
      if (sendRes['code'] != 0) {
        _toast(sendRes['msg']?.toString() ?? '验证码发送失败');
        return;
      }
      final code = (sendRes['data'] as Map<String, dynamic>?)?['code']?.toString() ?? '';
      if (code.isEmpty) {
        _toast('未获取到验证码');
        return;
      }

      // 3. 自动注册（手机号可能已存在则忽略）
      final regRes = await ApiService.register(phone, pwd, nickname: '测试用户', code: code);
      if (regRes['code'] != 0 && !regRes['msg'].toString().contains('已存在') && !regRes['msg'].toString().contains('已注册')) {
        _toast(regRes['msg']?.toString() ?? '自动注册失败');
        return;
      }

      // 4. 注册成功后再次登录
      final loginRes2 = await ApiService.login(phone, pwd);
      if (loginRes2['code'] == 0) {
        final data = loginRes2['data'] as Map<String, dynamic>?;
        final token = data?['token']?.toString();
        final user = data?['user'] as Map<String, dynamic>?;
        if (token == null || token.isEmpty || user == null) {
          _toast('一键登录返回数据异常');
          return;
        }
        await ApiService.setToken(token);
        await ApiService.setUserInfo(user);
        if (!mounted) return;
        _toast('一键登录成功');
        Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const MainPage()));
      } else {
        _toast(loginRes2['msg']?.toString() ?? '登录失败');
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
            colors: [AppStyles.bg, Color(0xFFFFECB3)],
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
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppStyles.primaryLight, width: 3),
                  ),
                  child: const FaIcon(FontAwesomeIcons.user, size: 64, color: AppStyles.textSub),
                ),
                const SizedBox(height: 40),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _loading ? null : _oneKeyLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppStyles.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            foregroundColor: AppStyles.primary,
                          ),
                          child: const Text('一键登录（免输账号）'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const ResetPwdPage())),
                            child: const Text('忘记密码', style: TextStyle(color: AppStyles.primary)),
                          ),
                          TextButton(
                            onPressed: _loading ? null : _oneKeyLogin,
                            child: const Text('一键登录', style: TextStyle(color: AppStyles.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('还没有账号？', style: TextStyle(color: AppStyles.textLight)),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const RegisterPage())),
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
