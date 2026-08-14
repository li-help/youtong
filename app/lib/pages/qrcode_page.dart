import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

class QrcodePage extends StatefulWidget {
  const QrcodePage({super.key});

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final u = await ApiService.getUserInfo();
    setState(() => _user = u);
  }

  // 生成可被扫码识别的真实内容（包含用户唯一标识）
  String get _qrData {
    final id = _user?['id'];
    final username = _user?['username']?.toString() ?? '';
    return 'youtong:user:${id ?? 0}:$username';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('我的二维码', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(40),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(color: Color(0xFFFFECB3), shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(_user?['nickname']?.toString() ?? _user?['username']?.toString() ?? '优童用户', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('扫一扫，添加我为好友', style: TextStyle(color: AppStyles.textLight)),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: AppStyles.primary, width: 8), borderRadius: BorderRadius.circular(16)),
                    child: _user == null
                        ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                        : QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 176,
                            backgroundColor: Colors.white,
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
}
