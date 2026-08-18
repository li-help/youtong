import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

/// 忘记密码：手机号 + 验证码 + 新密码 重置密码
class ResetPwdPage extends StatefulWidget {
  const ResetPwdPage({super.key});

  @override
  State<ResetPwdPage> createState() => _ResetPwdPageState();
}

class _ResetPwdPageState extends State<ResetPwdPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _counting = false;
  int _count = 60;

  Future<void> _sendCode() async {
    final phone = _phone.text.trim();
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
      _toast('验证码发送失败，请检查网络');
    }
  }

  Future<void> _reset() async {
    final phone = _phone.text.trim();
    final code = _code.text.trim();
    final pwd = _newPwd.text;
    final confirm = _confirm.text;

    if (phone.isEmpty || code.isEmpty || pwd.isEmpty) {
      _toast('请填写完整信息');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _toast('请输入有效的手机号');
      return;
    }
    if (pwd.length < 6) {
      _toast('新密码不能少于6位');
      return;
    }
    if (pwd != confirm) {
      _toast('两次密码不一致');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.resetPwdByCode(phone, code, pwd);
      if (res['code'] == 0) {
        if (!mounted) return;
        _toast('密码重置成功，请重新登录');
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.of(context).pop();
        });
      } else {
        _toast(res['msg']?.toString() ?? '重置失败');
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
              child: Text('重置密码', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: _input('请输入手机号')),
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
                  const SizedBox(height: 16),
                  TextField(controller: _newPwd, obscureText: true, decoration: _input('请输入新密码')),
                  const SizedBox(height: 16),
                  TextField(controller: _confirm, obscureText: true, decoration: _input('请再次输入新密码')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _reset,
                      style: AppStyles.primaryButton,
                      child: _loading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('确认重置'),
                    ),
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
