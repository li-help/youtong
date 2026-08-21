import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';

class ActivityDetailPage extends StatefulWidget {
  final int id;
  const ActivityDetailPage({super.key, required this.id});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _error = false;
  bool _fav = false;
  bool _favBusy = false;
  bool _showJoin = false;
  bool _joining = false;
  final TextEditingController _joinName = TextEditingController();
  final TextEditingController _joinPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _joinName.dispose();
    _joinPhone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.activityDetail(widget.id);
      setState(() {
        _detail = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
      _loadFavStatus();
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  Future<void> _loadFavStatus() async {
    try {
      final res = await ApiService.favoriteStatus('activity', widget.id);
      final data = res['data'];
      final fav = data is bool ? data : (data is Map ? (data['favorited'] == true || data['favorite'] == true) : false);
      if (mounted) setState(() => _fav = fav);
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (_favBusy || _detail == null) return;
    setState(() => _favBusy = true);
    try {
      final payload = {
        'targetType': 'activity',
        'targetId': widget.id,
        'title': _detail?['title']?.toString() ?? '',
        'cover': _detail?['cover']?.toString() ?? '',
      };
      if (_fav) {
        await ApiService.removeFavorite(payload);
      } else {
        await ApiService.addFavorite(payload);
      }
      if (!mounted) return;
      setState(() {
        _fav = !_fav;
        _favBusy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_fav ? '收藏成功' : '已取消收藏')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _favBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败：${e.toString()}')));
    }
  }

  void _openJoin() {
    _joinName.clear();
    _joinPhone.clear();
    setState(() => _showJoin = true);
  }

  Future<void> _submitJoin() async {
    final name = _joinName.text.trim();
    final phone = _joinPhone.text.trim();
    if (name.isEmpty) {
      _toast('请输入联系人姓名');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _toast('请输入有效的手机号');
      return;
    }
    setState(() => _joining = true);
    try {
      await ApiService.createOrder({
        'courseName': _detail?['title']?.toString() ?? '活动报名',
        'price': _detail?['price'] ?? 0,
        'contactName': name,
        'contactPhone': phone,
        'remark': '活动报名',
      });
      if (!mounted) return;
      setState(() {
        _joining = false;
        _showJoin = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('报名成功，请准时参加')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _joining = false);
      _toast('报名失败：${e.toString()}');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?['title']?.toString() ?? '活动详情';
    final views = _detail?['viewCount'] ?? 0;
    final price = _detail?['price'];
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: _loading
          ? _skeletonView()
          : _error
              ? SafeArea(child: AppErrorRetry(onRetry: _load))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 96),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 260,
                                width: double.infinity,
                                color: const Color(0xFFFFCC80),
                                child: _detail?['cover'] != null
                                    ? AppNetworkImage(
                                        url: _detail!['cover']?.toString(),
                                        width: double.infinity,
                                        height: 260,
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(child: FaIcon(FontAwesomeIcons.cakeCandles, size: 80, color: Colors.white)),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top + 12,
                                left: 16,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(22)),
                                    child: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.black87),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top + 12,
                                right: 16,
                                child: GestureDetector(
                                  onTap: _favBusy ? null : _toggleFav,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(22)),
                                    child: FaIcon(
                                      _fav ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                                      size: 22,
                                      color: _fav ? const Color(0xFFFFB300) : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        color: AppStyles.bg,
                                        child: const Text('活动', style: TextStyle(color: AppStyles.primary)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('$views次浏览', style: const TextStyle(color: AppStyles.textLight)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(_detail?['content']?.toString() ?? _detail?['description']?.toString() ?? '暂无详情内容', style: const TextStyle(fontSize: 15, color: AppStyles.textSub, height: 1.8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))]),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('活动价', style: TextStyle(fontSize: 12, color: AppStyles.textLight)),
                                Text(price != null ? '¥$price' : '免费', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppStyles.primary)),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _openJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text('立即报名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showJoin) _joinDialog(),
                  ],
                ),
    );
  }

  Widget _joinDialog() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _joining ? null : () => setState(() => _showJoin = false),
        child: Container(
          color: Colors.black45,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('活动报名', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_detail?['title']?.toString() ?? '活动', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppStyles.textLight)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _joinName,
                    enabled: !_joining,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: '联系人姓名',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _joinPhone,
                    enabled: !_joining,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: '联系人手机号',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _joining ? null : _submitJoin,
                    style: AppStyles.primaryButton,
                    child: Text(_joining ? '提交中...' : '确认报名'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _joining ? null : () => setState(() => _showJoin = false),
                    child: const Text('取消', style: TextStyle(color: Color(0xFF999999))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeletonView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 260, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 180, height: 24, borderRadius: 4),
                const SizedBox(height: 16),
                const AppSkeleton(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 24),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const AppSkeleton(width: 200, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
