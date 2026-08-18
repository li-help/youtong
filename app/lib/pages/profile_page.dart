import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nickname = TextEditingController();
  final _phone = TextEditingController();
  String? _avatar;
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
        _avatar = u['avatar']?.toString();
      }
    } catch (e) {
      // 未登录时回退到本地缓存
      final u = await ApiService.getUserInfo();
      _nickname.text = u?['nickname']?.toString() ?? u?['username']?.toString() ?? '';
      _avatar = u?['avatar']?.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeAvatar() async {
    final urlController = TextEditingController(text: _avatar ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更换头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请输入图片地址（支持 http/https 链接）', style: TextStyle(fontSize: 13, color: AppStyles.textSub)),
            const SizedBox(height: 12),
            TextField(controller: urlController, decoration: const InputDecoration(hintText: 'https://...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(urlController.text.trim()), child: const Text('确定')),
        ],
      ),
    );
    if (url != null && url.isNotEmpty && mounted) {
      setState(() => _avatar = url);
    }
  }

  Future<void> _save() async {
    if (_nickname.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('昵称不能为空')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(_nickname.text.trim(), avatar: _avatar);
      await ApiService.setUserInfo({'nickname': _nickname.text.trim(), 'username': _phone.text, 'avatar': _avatar});
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
                            InkWell(
                              onTap: _changeAvatar,
                              borderRadius: BorderRadius.circular(28),
                              child: Row(
                                children: [
                                  const SizedBox(width: 80, child: Text('头像', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ClipOval(
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: _avatar != null && _avatar!.isNotEmpty
                                          ? AppNetworkImage(url: _avatar!, fit: BoxFit.cover)
                                          : const ColoredBox(color: Color(0xFFFFECB3), child: FaIcon(FontAwesomeIcons.user, size: 32)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('点击更换', style: TextStyle(fontSize: 12, color: AppStyles.textSub)),
                                ],
                              ),
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
