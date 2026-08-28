import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_page_header.dart';
import '../widgets/app_skeleton.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppPageHeader(title: '我的二维码', showBack: true),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(40),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: AppStyles.amberSoft, shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.user, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      _user?['nickname']?.toString() ??
                          _user?['username']?.toString() ??
                          '优童用户',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('扫一扫，添加我为好友',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppStyles.textLight)),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppStyles.primary, width: 8),
                        borderRadius: BorderRadius.circular(16)),
                    child: _user == null
                        ? const Center(
                            child: AppSkeleton(
                                width: 120, height: 120, borderRadius: 12))
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
