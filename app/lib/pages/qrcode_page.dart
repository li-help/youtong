import 'dart:math';
import 'package:flutter/material.dart';
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

  bool _isBlack(int i) {
    final seed = (_user?['id'] ?? 1) + i;
    final v = (sin(seed * 12.9898) * 43758.5453) % 1;
    return (v < 0 ? v + 1 : v) > 0.4;
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
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 2, mainAxisSpacing: 2),
                      itemCount: 64,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) => Container(color: _isBlack(i) ? Colors.black : Colors.white),
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
