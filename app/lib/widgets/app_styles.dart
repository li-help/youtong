import 'package:flutter/material.dart';

/// 优童 App 全局设计令牌（Design Tokens）
/// 与 uniapp 端 / 后端设计系统对齐：主色 #FF9F2E，渐变辅色 #F6B51E。
class AppStyles {
  // —— 主色板（与 uniapp global.css / 后端统一）——
  static const Color primary = Color(0xFFFF9F2E); // 主橙（渐变起）
  static const Color primaryLight = Color(0xFFF6B51E); // 亮黄（渐变止）
  static const Color primarySoft = Color(0xFFFFF6E5); // 主色浅底
  static const Color primaryText = Color(0xFFE89B00); // 主色文字（深橙）

  static const Color bg = Color(0xFFF5F6FA); // 页面背景（中性浅灰）
  static const Color bgWarm = Color(0xFFFFF9EC); // 暖黄背景
  static const Color card = Colors.white;
  static const Color textMain = Color(0xFF2D2D2D);
  static const Color textSub = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color line = Color(0xFFF0F0F0);

  static const Color danger = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);

  // —— 语义化辅助色（替代各页硬编码的浅橙/米橙）——
  static const Color orangeSoft = Color(0xFFFFCC80); // 图片占位橙
  static const Color amberSoft = Color(0xFFFFECB3); // 浅琥珀底
  static const Color price = Color(0xFFFF6F00); // 价格/强调橙红

  // 订单/状态色
  static const Color statusPaid = Color(0xFF2196F3); // 已支付-蓝
  static const Color statusDone = Color(0xFF4CAF50); // 已完成-绿
  static const Color statusCancel = Color(0xFF9E9E9E); // 已取消-灰

  // —— 渐变 ——
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // —— 装饰 ——
  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  // 主按钮样式
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  // 输入框统一样式（login/register/reset_pwd 复用）
  static InputDecoration inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textLight),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    );
  }
}
