import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/im_chat_service.dart';
import '../widgets/app_styles.dart';

/// 门店客服聊天页：AI/FAQ 先答 + 转门店人工（WebSocket 实时通信）+ 结束后评价
class StoreChatPage extends StatefulWidget {
  final int storeId;
  final String? storeName;
  const StoreChatPage({super.key, required this.storeId, this.storeName});

  @override
  State<StoreChatPage> createState() => _StoreChatPageState();
}

class _Msg {
  String? clientMsgId;
  int senderType; // 1-用户 2-人工客服 3-AI/FAQ 4-系统通知
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

class _StoreChatPageState extends State<StoreChatPage> {
  final List<_Msg> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  bool _loading = false;
  int _sessionType = 1; // 1-AI 接待 2-人工客服
  int? _sessionId;
  bool _loggedIn = false;
  bool _showRatingBar = false;
  bool _rated = false;

  String get _title => widget.storeName?.isNotEmpty == true ? '${widget.storeName}' : '门店客服';

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      senderType: 3,
      content: widget.storeName?.isNotEmpty == true
          ? '您好～我是${widget.storeName}的客服，可为您咨询该门店的课程、活动与预约事宜，需要人工服务请点击上方按钮。'
          : '您好～我是本店客服，可为您咨询课程、活动与预约事宜，需要人工服务请点击上方按钮。',
    ));
    _init();
  }

  Future<void> _init() async {
    final token = await ApiService.getToken();
    _loggedIn = token != null && token.isNotEmpty;
    if (!_loggedIn) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final session = await ApiService.imInitSession(storeId: widget.storeId);
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

    ImChatService.instance.connect();
    _wsSub = ImChatService.instance.stream.listen(_onWsMessage);
  }

  void _onWsMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    if (data['type'] == 'chat' && data['message'] is Map) {
      final msg = (data['message'] as Map).cast<String, dynamic>();
      final msgSessionId = int.tryParse(msg['sessionId']?.toString() ?? '');
      if (msgSessionId != null && msgSessionId != _sessionId) return;
      final senderType = int.tryParse(msg['senderType']?.toString() ?? '0') ?? 0;
      if (senderType != 1) {
        setState(() => _messages.add(_Msg.fromHistory(msg)));
        _scrollToBottom();
      }
    } else if (data['type'] == 'transfer') {
      final sid = int.tryParse(data['sessionId']?.toString() ?? '');
      if (sid != null && sid != _sessionId) return;
      _sessionType = 2;
      final msg = data['message'];
      setState(() {
        if (msg is Map) {
          _messages.add(_Msg(senderType: 4, content: msg['content']?.toString() ?? ''));
        }
      });
      _scrollToBottom();
    } else if (data['type'] == 'session_close') {
      final sid = int.tryParse(data['sessionId']?.toString() ?? '');
      if (sid != null && sid != _sessionId) return;
      _sessionType = 1;
      if (!_rated) _showRatingBar = true;
      final msg = data['message'];
      setState(() {
        if (msg is Map) {
          _messages.add(_Msg(senderType: 4, content: msg['content']?.toString() ?? ''));
        }
      });
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
      _sessionId ??= int.tryParse((await ApiService.imInitSession(storeId: widget.storeId))['data']?['id']?.toString() ?? '');
      if (_sessionId == null) throw Exception('会话初始化失败');
      final res = await ApiService.imTransfer(_sessionId!);
      final notice = res['data']?['notice']?.toString();
      setState(() {
        _sessionType = 2;
        _messages.add(_Msg(senderType: 4, content: notice ?? '已为您转接人工客服，请直接输入您的问题。'));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已接通门店客服'), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('转接失败，请稍后重试'), behavior: SnackBarBehavior.floating));
      }
    }
    _scrollToBottom();
  }

  Future<void> _submitRating(int score) async {
    try {
      await ApiService.imRate(_sessionId!, score);
      setState(() {
        _rated = true;
        _showRatingBar = false;
        _messages.add(_Msg(senderType: 4, content: '已提交评价：$score 星，感谢您的反馈！'));
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('评价失败，请重试'), behavior: SnackBarBehavior.floating));
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
      _messages.add(_Msg(senderType: 3, content: '网络开小差了，请重试，或转接门店人工客服。'));
    } finally {
      _loading = false;
      if (mounted) setState(() {});
      _scrollToBottom();
    }
  }

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
      appBar: AppBar(
        backgroundColor: AppStyles.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
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
                    human ? '门店人工客服服务中' : 'AI 智能助手接待中',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppStyles.textMain),
                  ),
                ),
                human
                    ? const Text('门店客服',
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
                          child: const Text('👨‍💼 转门店人工',
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
              itemCount: _messages.length + 1,
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  if (_loading) return _botBubble(_Msg(senderType: 3, content: '正在思考并查询知识库...'));
                  return const SizedBox(height: 8);
                }
                final m = _messages[i];
                if (m.senderType == 4) return _systemRow(m.content);
                if (m.senderType == 1) return _userBubble(m);
                return m.senderType == 2 ? _csBubble(m) : _botBubble(m);
              },
            ),
          ),
          // 满意度评价条
          if (_showRatingBar) _ratingBar(),
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
                      hintText: human ? '向门店客服发送消息...' : '输入育儿问题，或输入“转人工”...',
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
    );
  }

  Widget _ratingBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF9F2),
      child: Row(
        children: [
          const Text('为本次门店服务评分：',
              style: TextStyle(fontSize: 12, color: AppStyles.textMain)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => _submitRating(i + 1),
                  child: const Text('⭐', style: TextStyle(fontSize: 18)),
                );
              }),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showRatingBar = false),
            child: const Text('跳过',
                style: TextStyle(fontSize: 11, color: AppStyles.textLight)),
          ),
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
