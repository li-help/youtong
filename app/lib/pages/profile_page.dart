import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nickname = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.userMe();
      final u = res['data'];
      if (u != null) {
        _nickname.text = u['nickname']?.toString() ?? u['username']?.toString() ?? '';
        _phone.text = u['phone']?.toString() ?? '';
      }
    } catch (e) {
      // 未登录时回退到本地缓存
      final u = await ApiService.getUserInfo();
      _nickname.text = u?['nickname']?.toString() ?? u?['username']?.toString() ?? '';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_nickname.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('昵称不能为空')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(_nickname.text.trim());
      await ApiService.setUserInfo({'nickname': _nickname.text.trim(), 'username': _phone.text});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功')));
        Future.delayed(const Duration(milliseconds: 600), () => Navigator.of(context).pop(true));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败：$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
                  const Expanded(child: Text('修改个人信息', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyles.cardDecoration,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 80, child: Text('头像', style: TextStyle(fontWeight: FontWeight.bold))),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(color: Color(0xFFFFECB3), shape: BoxShape.circle),
                                  child: const FaIcon(FontAwesomeIcons.user, size: 32),
                                ),
                              ],
                            ),
                            const Divider(),
                            _field('昵称', _nickname),
                            _field('手机号', _phone, TextInputType.phone, true),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: AppStyles.primaryButton,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('保存'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, [TextInputType? type, bool disabled = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: c,
              enabled: !disabled,
              keyboardType: type,
              decoration: const InputDecoration(hintText: '请输入', border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
