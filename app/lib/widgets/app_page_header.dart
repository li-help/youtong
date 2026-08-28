import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_styles.dart';

/// 统一页面标题栏：白底、居中加粗标题，可选左侧返回按钮。
/// 与首页「首页」标题栏样式一致。
class AppPageHeader extends StatelessWidget {
  final String title;

  /// 是否显示左侧返回按钮（一级 Tab 页不显示，二级页面显示）
  final bool showBack;

  const AppPageHeader({super.key, required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textMain)),
          if (showBack)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppStyles.textMain,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(40, 48),
                ),
                child: const FaIcon(FontAwesomeIcons.chevronLeft, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
