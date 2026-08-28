import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_page_header.dart';

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
  bool _uploading = false;

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
        _nickname.text =
            u['nickname']?.toString() ?? u['username']?.toString() ?? '';
        _phone.text = u['phone']?.toString() ?? '';
        _avatar = u['avatar']?.toString();
      }
    } catch (e) {
      // 未登录时回退到本地缓存
      final u = await ApiService.getUserInfo();
      _nickname.text =
          u?['nickname']?.toString() ?? u?['username']?.toString() ?? '';
      _avatar = u?['avatar']?.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 从本地电脑选择图片并上传为新头像。
  /// 上传成功后立即保存到服务端并同步本地缓存。
  Future<void> _changeAvatar() async {
    if (_uploading) return;
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('打开文件选择器失败')));
      }
      return;
    }
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null || bytes.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final res =
          await ApiService.uploadFile(filename: file.name, bytes: bytes);
      if (res['code'] == 0 && res['data']?['url'] != null) {
        final url = res['data']['url'].toString();
        if (!mounted) return;
        setState(() => _avatar = url);
        // 立即持久化：更新服务端资料 + 本地缓存
        final nickname =
            _nickname.text.trim().isNotEmpty ? _nickname.text.trim() : '优童用户';
        await ApiService.updateProfile(nickname, avatar: url);
        final cached = await ApiService.getUserInfo();
        await ApiService.setUserInfo({
          ...?cached,
          'nickname': nickname,
          'avatar': url,
        });
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('头像已更新')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['msg']?.toString() ?? '上传失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('上传失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (_nickname.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('昵称不能为空')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(_nickname.text.trim(), avatar: _avatar);
      await ApiService.setUserInfo({
        'nickname': _nickname.text.trim(),
        'username': _phone.text,
        'avatar': _avatar
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存成功')));
        Future.delayed(const Duration(milliseconds: 600),
            () => Navigator.of(context).pop(true));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：$e')));
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
            const AppPageHeader(title: '个人信息', showBack: true),
            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyles.cardDecoration,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                    width: 80,
                                    child: Text('头像',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                ClipOval(
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: AppSkeleton(
                                        width: 56,
                                        height: 56,
                                        borderRadius: 28),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const Row(children: [
                              SizedBox(
                                  width: 80,
                                  child: Text('昵称',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child:
                                      AppSkeleton(height: 18, borderRadius: 4))
                            ]),
                            const Divider(),
                            const Row(children: [
                              SizedBox(
                                  width: 80,
                                  child: Text('手机号',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child:
                                      AppSkeleton(height: 18, borderRadius: 4))
                            ]),
                          ],
                        ),
                      ),
                    )
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
                                  const SizedBox(
                                      width: 80,
                                      child: Text('头像',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  ClipOval(
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: _uploading
                                          ? const ColoredBox(
                                              color: AppStyles.amberSoft,
                                              child: Center(
                                                  child: SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: AppStyles
                                                                  .primary))),
                                            )
                                          : _avatar != null &&
                                                  _avatar!.isNotEmpty
                                              ? AppNetworkImage(
                                                  url: _avatar!,
                                                  fit: BoxFit.cover)
                                              : const ColoredBox(
                                                  color: AppStyles.amberSoft,
                                                  child: FaIcon(
                                                      FontAwesomeIcons.user,
                                                      size: 32)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_uploading ? '上传中...' : '点击从本地选择图片更换',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppStyles.textSub)),
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

  Widget _field(String label, TextEditingController c,
      [TextInputType? type, bool disabled = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: c,
              enabled: !disabled,
              keyboardType: type,
              decoration: const InputDecoration(
                  hintText: '请输入', border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
