import 'package:flutter/material.dart';
import 'app_styles.dart';

class AppErrorRetry extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const AppErrorRetry({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppStyles.danger.withAlpha(153)),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppStyles.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? '请检查网络后重试',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppStyles.textSub),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
