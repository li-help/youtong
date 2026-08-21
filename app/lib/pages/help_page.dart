import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_styles.dart';

/// 使用说明
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      appBar: AppBar(
        title: const Text('使用说明'),
        backgroundColor: AppStyles.bg,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('快速上手'),
            _Step(number: 1, text: '注册 / 登录账号，完善宝宝信息'),
            _Step(number: 2, text: '在「首页」浏览课程、活动、视频'),
            _Step(number: 3, text: '在「智能」填写宝宝情况，获取推荐'),
            _Step(number: 4, text: '报名课程，在「我的订单」查看与核销'),
            const SizedBox(height: 24),
            const _SectionTitle('常见问题'),
            const _QA(
              q: 'Q：如何报名课程？',
              a: 'A：进入课程详情页，点击「立即报名」填写信息并提交即可。',
            ),
            const _QA(
              q: 'Q：订单如何核销？',
              a: 'A：在「我的订单」中找到已支付订单，点击「核销」由门店确认。',
            ),
            const _QA(
              q: 'Q：推荐不准怎么办？',
              a: 'A：可在「智能」页重新填写宝宝年龄、身高体重与兴趣偏好。',
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9F2E), AppStyles.primary]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppStyles.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('联系我们', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.phone, size: 14, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('客服电话：400-000-0000', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.clock, size: 14, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('工作时间：09:00 - 21:00', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ],
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF9F2E), AppStyles.primary]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('$number', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppStyles.textSub))),
        ],
      ),
    );
  }
}

class _QA extends StatelessWidget {
  final String q;
  final String a;
  const _QA({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE89B00))),
          const SizedBox(height: 6),
          Text(a, style: const TextStyle(fontSize: 13, color: AppStyles.textSub, height: 1.6)),
        ],
      ),
    );
  }
}
