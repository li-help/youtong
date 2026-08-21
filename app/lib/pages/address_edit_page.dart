import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

/// 新增 / 编辑收货地址
class AddressEditPage extends StatefulWidget {
  final dynamic address;
  const AddressEditPage({super.key, this.address});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _region;
  late final TextEditingController _detail;
  bool _isDefault = false;
  bool _saving = false;

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _name = TextEditingController(text: a?['name']?.toString() ?? '');
    _phone = TextEditingController(text: a?['phone']?.toString() ?? '');
    _region = TextEditingController(text: a?['region']?.toString() ?? '');
    _detail = TextEditingController(text: a?['detail']?.toString() ?? '');
    _isDefault = (a?['isDefault'] ?? 0) == 1 || (a?['isDefault'] ?? false) == true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _region.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'region': _region.text.trim(),
        'detail': _detail.text.trim(),
        'isDefault': _isDefault ? 1 : 0,
      };
      if (_isEdit) payload['id'] = (widget.address['id'] as num).toInt();
      await ApiService.saveAddress(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败：${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: Text(_isEdit ? '编辑地址' : '新增地址'),
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: AppStyles.cardDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _field(
                    label: '收货人',
                    child: TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(hintText: '请输入收货人姓名'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '请填写收货人姓名' : null,
                    ),
                  ),
                  _field(
                    label: '联系电话',
                    child: TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      decoration: const InputDecoration(hintText: '请输入手机号', counterText: ''),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return '请输入手机号';
                        if (!RegExp(r'^1\d{10}$').hasMatch(s)) return '请输入正确的手机号';
                        return null;
                      },
                    ),
                  ),
                  _field(
                    label: '所在地区',
                    child: TextFormField(
                      controller: _region,
                      decoration: const InputDecoration(hintText: '如：广东省 深圳市 南山区'),
                    ),
                  ),
                  _field(
                    label: '详细地址',
                    child: TextFormField(
                      controller: _detail,
                      maxLines: 2,
                      maxLength: 120,
                      decoration: const InputDecoration(hintText: '街道、门牌号等详细信息', counterText: ''),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '请填写详细地址' : null,
                    ),
                  ),
                  _field(
                    label: '设为默认地址',
                    child: Switch(
                      value: _isDefault,
                      activeThumbColor: AppStyles.primary,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const FaIcon(FontAwesomeIcons.check, size: 16),
              label: Text(_saving ? '保存中...' : '保存地址'),
              style: AppStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppStyles.textMain)),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
