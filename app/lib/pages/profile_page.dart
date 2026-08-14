import 'package:flutter/material.dart';
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
  final _babyName = TextEditingController();
  String? _babyAge;
  final _ageOptions = ['0-1岁', '1-3岁', '3-6岁', '6岁以上'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final u = await ApiService.getUserInfo();
    setState(() {
      _nickname.text = u?['nickname']?.toString() ?? u?['username']?.toString() ?? '';
      _phone.text = u?['phone']?.toString() ?? '';
    });
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功')));
    Future.delayed(const Duration(milliseconds: 800), () => Navigator.of(context).pop());
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
              child: SingleChildScrollView(
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
                            child: const Icon(Icons.person_outline, size: 32),
                          ),
                        ],
                      ),
                      const Divider(),
                      _field('昵称', _nickname),
                      _field('手机号', _phone, TextInputType.phone),
                      _field('宝宝姓名', _babyName),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('宝宝年龄'),
                        trailing: DropdownButton<String>(
                          hint: const Text('请选择'),
                          value: _babyAge,
                          items: _ageOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                          onChanged: (v) => setState(() => _babyAge = v),
                        ),
                      ),
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
                child: ElevatedButton(onPressed: _save, style: AppStyles.primaryButton, child: const Text('保存')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, [TextInputType? type]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: type,
              decoration: const InputDecoration(hintText: '请输入', border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
