import 'package:flutter/material.dart';
import 'app_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onRefresh;

  const AppEmptyState({super.key, this.title, this.subtitle, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppStyles.textLight.withAlpha(102)),
            const SizedBox(height: 16),
            Text(
              title ?? '暂无数据',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textMain),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppStyles.textSub),
              ),
            ],
            if (onRefresh != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新试试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
