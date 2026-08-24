import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_styles.dart';

/// 统一的返回按钮（替换各二级页手写的 44x44 圆形返回箭头）。
class AppBackButton extends StatelessWidget {
  final Color? bg; // 背景色，默认半透明白
  final Color? iconColor; // 箭头色，默认深色
  final VoidCallback? onPressed;

  const AppBackButton({
    super.key,
    this.bg,
    this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg ?? Colors.white.withOpacity(0.7),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: FaIcon(
          FontAwesomeIcons.arrowLeft,
          size: 18,
          color: iconColor ?? AppStyles.textMain,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
