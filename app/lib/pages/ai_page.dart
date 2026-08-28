import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/im_chat_service.dart';
import '../widgets/app_styles.dart';

/// 聊天消息模型
/// senderType: 1-用户 2-人工客服 3-AI/FAQ 4-系统通知
class _Msg {
  String? clientMsgId;
  int senderType;
  String content;
  String status; // sending / success / fail
  _Msg({
    this.clientMsgId,
    required this.senderType,
    required this.content,
    this.status = 'success',
  });

  factory _Msg.fromHistory(Map<String, dynamic> h) => _Msg(
        clientMsgId: h['clientMsgId']?.toString(),
        senderType: int.tryParse(h['senderType']?.toString() ?? '3') ?? 3,
        content: h['content']?.toString() ?? '',
      );
}

/// AI 智能客服：AI/FAQ 自动应答 + 一键转人工（WebSocket 实时通信）
class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final List<_Msg> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  bool _loading = false;
  int _sessionType = 1; // 1-AI 接待 2-人工客服
  int? _sessionId;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      senderType: 3,
      content: '家长您好～我是优童 AI 智能客服，您可以咨询任何育儿知识、入园指南与课程服务，也可以随时点击上方按钮转接人工客服哦！',
    ));
    _init();
  }

  Future<void> _init() async {
    final token = await ApiService.getToken();
    _loggedIn = token != null && token.isNotEmpty;
    if (!_loggedIn) return;

    // 初始化/获取会话并加载历史消息
    try {
      final session = await ApiService.imInitSession();
      final data = session['data'];
      if (data != null && data['id'] != null) {
        _sessionId = int.tryParse(data['id'].toString());
        _sessionType = int.tryParse(data['sessionType']?.toString() ?? '1') ?? 1;
        final history = await ApiService.imHistory(_sessionId!);
        final list = history['data'];
        if (list is List && list.isNotEmpty) {
          _messages
            ..clear()
            ..addAll(list.map((h) => _Msg.fromHistory(h as Map<String, dynamic>)));
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {});

    // 连接 WebSocket 并监听人工消息/转接通知推送
    ImChatService.instance.connect();
    _wsSub = ImChatService.instance.stream.listen(_onWsMessage);
  }

  void _onWsMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    if (data['type'] == 'chat' && data['message'] is Map) {
      final msg = (data['message'] as Map).cast<String, dynamic>();
      final msgSessionId = int.tryParse(msg['sessionId']?.toString() ?? '');
      // 只处理当前会话，避免串扰其他页面的会话
      if (msgSessionId != null && msgSessionId != _sessionId) return;
      final senderType = int.tryParse(msg['senderType']?.toString() ?? '0') ?? 0;
      if (senderType != 1) {
        setState(() => _messages.add(_Msg.fromHistory(msg)));
        _scrollToBottom();
      }
    } else if (data['type'] == 'transfer') {
      final transferSessionId = int.tryParse(data['sessionId']?.toString() ?? '');
      if (transferSessionId != null && transferSessionId != _sessionId) return;
      _sessionType = 2;
      final msg = data['message'];
      if (msg is Map) {
        setState(() => _messages
            .add(_Msg(senderType: 4, content: msg['content']?.toString() ?? '')));
      } else {
        setState(() {});
      }
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (!_loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录后再转接人工'), behavior: SnackBarBehavior.floating));
      return;
    }
    try {
      _sessionId ??= int.tryParse(
          (await ApiService.imInitSession())['data']?['id']?.toString() ?? '');
      if (_sessionId == null) throw Exception('会话初始化失败');
      final res = await ApiService.imTransfer(_sessionId!);
      final notice = res['data']?['notice']?.toString();
      setState(() {
        _sessionType = 2;
        _messages.add(_Msg(senderType: 4, content: notice ?? '已为您转接人工客服，请直接输入您的问题。'));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已接通人工客服'), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('转接失败，请稍后重试'), behavior: SnackBarBehavior.floating));
      }
    }
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    _input.clear();

    final userMsg = _Msg(
      clientMsgId: 'u_${DateTime.now().millisecondsSinceEpoch}',
      senderType: 1,
      content: text,
      status: 'sending',
    );
    setState(() => _messages.add(userMsg));
    _scrollToBottom();

    // 人工客服模式：走 WebSocket 实时收发
    if (_sessionType == 2) {
      try {
        await ImChatService.instance.sendMessage({
          'type': 'chat',
          'sessionId': _sessionId,
          'clientMsgId': userMsg.clientMsgId,
          'senderType': 1,
          'receiverId': 0,
          'msgType': 'text',
          'content': text,
        });
        setState(() => userMsg.status = 'success');
      } catch (_) {
        setState(() => userMsg.status = 'fail');
      }
      _scrollToBottom();
      return;
    }

    // AI 客服模式：/ai/service-chat（含 FAQ 匹配与转人工检测）
    setState(() => _loading = true);
    try {
      final res = await ApiService.aiServiceChat(
        message: text,
        sessionId: _sessionId,
        clientMsgId: userMsg.clientMsgId,
      );
      setState(() => userMsg.status = 'success');
      final data = res['data'];
      if (data is Map) {
        final type = data['type']?.toString();
        final sessionId = int.tryParse(data['sessionId']?.toString() ?? '');
        if (sessionId != null && sessionId > 0) _sessionId = sessionId;
        if (data['needTransfer'] == true || type == 'transfer') {
          _sessionType = 2;
        }
        _messages.add(_Msg(
          senderType: type == 'transfer' ? 4 : 3,
          content: data['content']?.toString().isNotEmpty == true
              ? data['content'].toString()
              : '我已收到您的问题。',
        ));
      }
    } on TimeoutException catch (_) {
      setState(() => userMsg.status = 'fail');
      _messages.add(_Msg(senderType: 3, content: '思考时间有点长，请稍后再试，或点击上方按钮转接人工客服。'));
    } catch (_) {
      setState(() => userMsg.status = 'fail');
      _messages.add(_Msg(senderType: 3, content: '网络开小差了，请重试，或转接人工客服。'));
    } finally {
      _loading = false;
      if (mounted) setState(() {});
      _scrollToBottom();
    }
  }

  /// 人工模式发送失败的消息重发（AI 模式的失败重发直接重新提问）
  Future<void> _retry(_Msg msg) async {
    setState(() => msg.status = 'sending');
    try {
      await ImChatService.instance.sendMessage({
        'type': 'chat',
        'sessionId': _sessionId,
        'clientMsgId': msg.clientMsgId,
        'senderType': 1,
        'receiverId': 0,
        'msgType': 'text',
        'content': msg.content,
      });
      setState(() => msg.status = 'success');
    } catch (_) {
      setState(() => msg.status = 'fail');
    }
    _scrollToBottom();
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
    final human = _sessionType == 2;
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
              child: const Text('优童智能客服',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
            ),
            // 客服状态条 + 转人工按钮
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: human ? const Color(0xFFF0F9FF) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: human ? const Color(0xFFBAE6FD) : const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.6), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      human ? '人工客服在线服务中' : 'AI 智能助手接待中',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppStyles.textMain),
                    ),
                  ),
                  human
                      ? const Text('人工老师',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7)))
                      : GestureDetector(
                          onTap: _transfer,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppStyles.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppStyles.primary.withOpacity(0.3)),
                            ),
                            child: const Text('👨‍💼 转人工客服',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppStyles.primary)),
                          ),
                        ),
                ],
              ),
            ),
            // 消息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) return _hero();
                  if (i == _messages.length + 1) {
                    if (_loading) return _botBubble(_Msg(senderType: 3, content: '正在思考并查询知识库...'));
                    return SizedBox(height: bottom + 8);
                  }
                  final m = _messages[i - 1];
                  if (m.senderType == 4) return _systemRow(m.content);
                  if (m.senderType == 1) return _userBubble(m);
                  return m.senderType == 2 ? _csBubble(m) : _botBubble(m);
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
                        hintText: human
                            ? '向人工客服发送消息...'
                            : '输入育儿问题，或输入“转人工”...',
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
          const Text('优童智能客服', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
          const SizedBox(height: 6),
          const Text('支持 24 小时育儿咨询、课程活动解答与业务常见问题查询',
              style: TextStyle(fontSize: 13, color: AppStyles.textLight)),
        ],
      ),
    );
  }

  Widget _systemRow(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 11, color: AppStyles.textMain)),
      ),
    );
  }

  Widget _avatar(String emoji, {Color bg = Colors.white}) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6)]),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _botBubble(_Msg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar('🤖'),
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
              child: Text(m.content, style: const TextStyle(fontSize: 15, color: AppStyles.textMain, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _csBubble(_Msg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar('👨‍💼', bg: const Color(0xFFF0F9FF)),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                border: Border.all(color: const Color(0xFFBAE6FD)),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Text(m.content,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0369A1), height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userBubble(_Msg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
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
              child: Text(m.content, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5)),
            ),
          ),
          const SizedBox(width: 6),
          // 发送状态：发送中 / 失败点击重发
          if (m.status == 'sending')
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppStyles.textLight),
              ),
            )
          else if (m.status == 'fail')
            GestureDetector(
              onTap: () => _retry(m),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('⚠️ 重发', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ),
            ),
        ],
      ),
    );
  }
}
