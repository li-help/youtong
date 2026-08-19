import 'package:flutter/material.dart';

/// 统一页面转场动画：iOS 风格侧滑返回 + 自定义淡入缩放
class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({required super.builder, super.settings});

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final theme = Theme.of(context).pageTransitionsTheme;
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return theme.buildTransitions(this, context, animation, secondaryAnimation, child);
    }
    // Android / Web / 桌面使用向右滑入
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: animation.drive(Tween<double>(begin: 0.85, end: 1.0)),
        child: child,
      ),
    );
  }
}

/// 通用 push 方法
Future<T?> pushAppPage<T extends Object?>(
  BuildContext context, {
  required Widget page,
}) {
  return Navigator.of(context).push(AppPageRoute<T>(builder: (_) => page));
}
