// 基础冒烟测试：验证 WebSocket 地址推导逻辑
//
// 运行：flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:app/api/api_service.dart';

void main() {
  test('wsBaseUrl 应输出 ws/wss 协议地址', () {
    final url = ApiService.wsBaseUrl;
    expect(url.startsWith('ws://') || url.startsWith('wss://'), isTrue,
        reason: 'wsBaseUrl=$url 应以 ws:// 或 wss:// 开头');
    expect(url.contains('/api'), isFalse,
        reason: 'wsBaseUrl=$url 不应包含 /api 后缀');
  });
}
