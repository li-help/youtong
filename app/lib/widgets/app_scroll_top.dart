import 'package:flutter/material.dart';
import 'app_styles.dart';

/// 返回顶部浮动按钮
class AppScrollTopButton extends StatelessWidget {
  final ScrollController controller;
  final double visibleOffset;

  const AppScrollTopButton({
    super.key,
    required this.controller,
    this.visibleOffset = 300,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final show = controller.hasClients && controller.offset > visibleOffset;
        return AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !show,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton.small(
          onPressed: () {
            if (controller.hasClients) {
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            }
          },
          backgroundColor: AppStyles.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }
}
