import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api/api_service.dart';
import 'app_styles.dart';

/// 统一的网络图片组件，用于彻底解决"图像缺失"问题：
/// - URL 为 null / 空字符串 → 直接显示本地占位图
/// - URL 为相对路径（如 /uploads/xxx.jpg）→ 自动拼接后端地址为完整 URL
/// - 加载中 → 显示本地占位图（避免白屏）
/// - 加载失败 → 显示本地占位图并给出友好提示（不再出现破图/空白）
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// 网络图片地址（支持绝对 / 相对路径）
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  /// 本地兜底占位图（打包进 assets，任何情况下都可用）
  static const String kPlaceholder = 'assets/images/placeholder.png';

  /// 将原始 URL 解析为可加载的完整地址
  static String? resolveUrl(String? u) {
    if (u == null) return null;
    final s = u.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    // 相对路径：拼接后端地址（去掉 /api 前缀）
    final base = ApiService.baseUrl.replaceFirst(RegExp(r'/api/*$'), '');
    return '$base${s.startsWith('/') ? s : '/$s'}';
  }

  Widget _fallback({String hint = '暂无图片'}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 本地占位图，若资源异常再退化为纯色背景
          Image.asset(
            kPlaceholder,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppStyles.primaryLight),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.image, size: 16, color: AppStyles.textSub),
                  const SizedBox(width: 4),
                  Text(hint, style: const TextStyle(fontSize: 12, color: AppStyles.textSub)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveUrl(url);
    if (resolved == null) {
      return _fallback();
    }
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: resolved,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => _fallback(hint: '加载中...'),
        errorWidget: (_, __, ___) => _fallback(hint: '图片加载失败'),
      ),
    );
  }
}
