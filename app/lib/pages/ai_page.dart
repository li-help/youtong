import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';

/// AI 智能助手（聊天对话）
class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'content': '你好呀～我可以根据宝宝的年龄和兴趣，为你推荐合适的课程和活动哦！',
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _input.clear();
      _loading = true;
    });
    _scrollToBottom();

    try {
      final history = _messages.map((m) => {
        'role': m['role'] == 'user' ? 'user' : 'assistant',
        'content': m['content'] ?? '',
      }).toList();
      final res = await ApiService.aiChat(history);
      final reply = res['data'] is Map
          ? (res['data']['content']?.toString() ?? '抱歉，我暂时无法回答，请稍后再试～')
          : '抱歉，我暂时无法回答，请稍后再试～';
      setState(() => _messages.add({'role': 'bot', 'content': reply}));
    } on TimeoutException catch (_) {
      setState(() => _messages.add({'role': 'bot', 'content': '思考时间有点长，请稍后再试～'}));
    } catch (e) {
      setState(() => _messages.add({'role': 'bot', 'content': '网络有点忙，请稍后再问我哦～'}));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题
            Container(
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6FA),
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
              ),
              child: const Text('AI 智能助手', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
            ),
            // 欢迎区 + 消息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) return _hero();
                  if (i == _messages.length + 1) {
                    if (_loading) return _botBubble('正在思考...');
                    return SizedBox(height: bottom + 8);
                  }
                  final m = _messages[i - 1];
                  return m['role'] == 'user' ? _userBubble(m['content'] ?? '') : _botBubble(m['content'] ?? '');
                },
              ),
            ),
            // 底部输入栏
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      maxLines: 4,
                      minLines: 1,
                      decoration: AppStyles.inputDecoration(
                        hintText: '输入宝宝年龄、兴趣或问题...',
                      ).copyWith(
                        fillColor: AppStyles.bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppStyles.primary, AppStyles.primaryLight]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x33F6B51E), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppStyles.primary, AppStyles.primaryLight]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33F6B51E), blurRadius: 20, offset: Offset(0, 8))],
            ),
            alignment: Alignment.center,
            child: const Text('🤖', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 14),
          const Text('AI智能体', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
          const SizedBox(height: 6),
          const Text('嗨～我是你的育儿小助手，有什么可以帮你的吗？', style: TextStyle(fontSize: 13, color: AppStyles.textLight)),
        ],
      ),
    );
  }

  Widget _botBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 6)]),
            alignment: Alignment.center,
            child: const Text('🤖', style: TextStyle(fontSize: 16)),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8)],
              ),
              child: Text(text, style: const TextStyle(fontSize: 15, color: AppStyles.textMain, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppStyles.primary, AppStyles.primaryLight]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [BoxShadow(color: Color(0x1AF6B51E), blurRadius: 8)],
              ),
              child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
