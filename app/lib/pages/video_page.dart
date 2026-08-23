import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import '../api/api_service.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_error_retry.dart';

class VideoPage extends StatefulWidget {
  final int id;
  const VideoPage({super.key, required this.id});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Map<String, dynamic>? _detail;
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.videoDetail(widget.id);
      final d = res['data'] as Map<String, dynamic>?;
      setState(() => _detail = d);
      final url = d?['url']?.toString();
      if (url != null && url.isNotEmpty) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _controller?.play();
            }
          }).catchError((_) {
            if (mounted) setState(() {});
          });
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSkeleton(width: 120, height: 120, borderRadius: 16),
                    const SizedBox(height: 16),
                    const AppSkeleton(width: 120, height: 16, borderRadius: 4),
                  ],
                ),
              )
            : _error
                ? AppErrorRetry(
                    onRetry: () async {
                      _controller?.dispose();
                      _controller = null;
                      await _load();
                    },
                  )
                : Stack(
                    children: [
                      Center(
                        child: _controller != null && _controller!.value.isInitialized
                            ? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!))
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.circlePlay, size: 64, color: Colors.white54),
                                  SizedBox(height: 12),
                                  Text('暂无视频源', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
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
                            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(22)),
                            child: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      if (!_loading && _detail != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            color: Colors.black54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_detail!['title']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(_detail!['description']?.toString() ?? '精彩儿童教育视频', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
