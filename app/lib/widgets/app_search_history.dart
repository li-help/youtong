import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';

class AppSearchHistory extends StatefulWidget {
  final ValueChanged<String> onTap;
  final VoidCallback? onChanged;

  const AppSearchHistory({super.key, required this.onTap, this.onChanged});

  static const _key = 'search_history';

  static Future<void> save(String keyword) async {
    if (keyword.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > 12) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  @override
  State<AppSearchHistory> createState() => _AppSearchHistoryState();
}

class _AppSearchHistoryState extends State<AppSearchHistory> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppSearchHistory._key) ?? [];
    setState(() => _history = list);
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppSearchHistory._key);
    setState(() => _history = []);
  }

  Future<void> _remove(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppSearchHistory._key) ?? [];
    list.remove(keyword);
    await prefs.setStringList(AppSearchHistory._key, list);
    setState(() => _history = list);
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('搜索历史', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
              GestureDetector(
                onTap: _clear,
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: AppStyles.textSub),
                    SizedBox(width: 4),
                    Text('清空', style: TextStyle(fontSize: 12, color: AppStyles.textSub)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _history.map((k) => _chip(k)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String keyword) {
    return GestureDetector(
      onTap: () => widget.onTap(keyword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(keyword, style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _remove(keyword),
              child: const Icon(Icons.close, size: 14, color: AppStyles.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
