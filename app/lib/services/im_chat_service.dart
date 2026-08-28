import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/api_service.dart';

/// 客服 IM WebSocket 服务（与 uniapp 端 utils/imChatService.js 协议一致）
///
/// 协议：
/// - 上行：{type:'chat', sessionId, clientMsgId, senderType, receiverId, content}
/// - 上行心跳：{type:'ping'} -> 下行 {type:'pong'}
/// - 下行 ACK：{type:'ACK', clientMsgId, msgId, createdAt}（消息入库确认）
/// - 下行推送：{type:'chat', message:{...}} / {type:'transfer', ...}
class ImChatService {
  ImChatService._();

  static final ImChatService instance = ImChatService._();

  WebSocketChannel? _channel;
  bool _connected = false;
  bool _connecting = false;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  /// clientMsgId -> ACK 等待器
  final Map<String, Completer<void>> _pending = {};

  /// 服务端推送（chat / transfer / pong 等）广播流
  final StreamController<Map<String, dynamic>> _pushes =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _pushes.stream;
  bool get isConnected => _connected;

  Future<void> connect() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) return;
    if (_connected || _connecting) return;

    _connecting = true;
    try {
      final channel =
          WebSocketChannel.connect(Uri.parse('${ApiService.wsBaseUrl}/ws/im?token=$token'));
      await channel.ready.timeout(const Duration(seconds: 10));
      _channel = channel;
      _connected = true;
      _connecting = false;
      _startHeartbeat();

      channel.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data.toString()) as Map<String, dynamic>;
            if (msg['type'] == 'ACK' && msg['clientMsgId'] != null) {
              final c = _pending.remove(msg['clientMsgId']);
              if (c != null && !c.isCompleted) c.complete();
            } else {
              _pushes.add(msg);
            }
          } catch (_) {}
        },
        onError: (_) => _onClosed(),
        onDone: _onClosed,
      );
    } catch (_) {
      _connecting = false;
      _reconnect();
    }
  }

  /// 发送聊天消息，等待服务端 ACK（6 秒超时视为失败）
  Future<void> sendMessage(Map<String, dynamic> msg) async {
    final clientMsgId = (msg['clientMsgId'] as String?) ??
        'u_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(0x7fffffff)}';
    msg['clientMsgId'] = clientMsgId;

    if (!_connected || _channel == null) {
      await connect();
      if (!_connected) throw Exception('客服连接未就绪');
    }

    final completer = Completer<void>();
    _pending[clientMsgId] = completer;
    _channel!.sink.add(jsonEncode(msg));

    Timer(const Duration(seconds: 6), () {
      final c = _pending.remove(clientMsgId);
      if (c != null && !c.isCompleted) {
        c.completeError(TimeoutException('等待回执超时'));

      }
    });

    await completer.future;
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_connected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      }
    });
  }

  void _onClosed() {
    if (!_connected) return;
    _connected = false;
    _channel = null;
    _pingTimer?.cancel();
    for (final c in _pending.values) {
      if (!c.isCompleted) c.completeError(Exception('连接已断开'));
    }
    _pending.clear();
    _reconnect();
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      _reconnectTimer = null;
      connect();
    });
  }

  void dispose() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _connected = false;
    _connecting = false;
  }
}
