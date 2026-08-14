import 'package:flutter/material.dart';

class AppStyles {
  static const Color primary = Color(0xFFFFA000);
  static const Color primaryLight = Color(0xFFFFC107);
  static const Color bg = Color(0xFFFFF8E1);
  static const Color card = Colors.white;
  static const Color textMain = Color(0xFF333333);
  static const Color textSub = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color danger = Color(0xFFFF5252);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(24),
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryLight,
    foregroundColor: const Color(0xFFB86E00),
    elevation: 0,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}
