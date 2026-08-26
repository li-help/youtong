package com.youtong.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.youtong.entity.ImMessage;
import com.youtong.service.ImMessageService;
import com.youtong.service.ImSessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * IM WebSocket 消息收发处理器
 */
@Component
public class ImWebSocketHandler extends TextWebSocketHandler {

    /** 在线用户连接池：userId -> WebSocketSession */
    private static final ConcurrentHashMap<Long, WebSocketSession> ONLINE_USERS = new ConcurrentHashMap<>();

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private ImMessageService messageService;

    @Autowired
    private ImSessionService sessionService;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            ONLINE_USERS.put(userId, session);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        try {
            String payload = message.getPayload();
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);
            String type = String.valueOf(data.getOrDefault("type", "chat"));

            // 1. 心跳保活
            if ("ping".equalsIgnoreCase(type)) {
                session.sendMessage(new TextMessage("{\"type\":\"pong\"}"));
                return;
            }

            // 2. 已读回执
            if ("read".equalsIgnoreCase(type)) {
                Long sessionId = data.get("sessionId") != null ? Long.valueOf(data.get("sessionId").toString()) : null;
                Long receiverId = (Long) session.getAttributes().get("userId");
                if (sessionId != null && receiverId != null) {
                    messageService.markAsRead(sessionId, receiverId);
                }
                return;
            }

            // 3. 聊天消息转发与持久化
            Long sessionId = data.get("sessionId") != null ? Long.valueOf(data.get("sessionId").toString()) : null;
            String clientMsgId = data.get("clientMsgId") != null ? data.get("clientMsgId").toString() : null;
            Integer senderType = data.get("senderType") != null ? Integer.valueOf(data.get("senderType").toString()) : 1;
            Long senderId = (Long) session.getAttributes().get("userId");
            Long receiverId = data.get("receiverId") != null ? Long.valueOf(data.get("receiverId").toString()) : 0L;
            String msgType = data.get("msgType") != null ? data.get("msgType").toString() : "text";
            String content = data.get("content") != null ? data.get("content").toString() : "";

            if (sessionId != null && content != null && !content.isBlank()) {
                // 入库保存
                ImMessage saved = messageService.saveMessage(sessionId, clientMsgId, senderType, senderId, receiverId, msgType, content);

                // 回复发送方 ACK
                Map<String, Object> ack = Map.of(
                        "type", "ACK",
                        "clientMsgId", clientMsgId != null ? clientMsgId : "",
                        "msgId", saved.getId(),
                        "createdAt", saved.getCreatedAt()
                );
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(ack)));

                // 转发给接收方（如果在线）
                if (receiverId != null && receiverId > 0) {
                    WebSocketSession targetSession = ONLINE_USERS.get(receiverId);
                    if (targetSession != null && targetSession.isOpen()) {
                        Map<String, Object> forward = Map.of(
                                "type", "chat",
                                "message", saved
                        );
                        targetSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(forward)));
                    }
                }
            }
        } catch (Exception e) {
            // 异常捕获，避免连接断开
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            ONLINE_USERS.remove(userId);
        }
    }

    /**
     * 服务端主动推送消息给指定用户
     */
    public void sendToUser(Long userId, Object messageObj) {
        if (userId == null) return;
        WebSocketSession session = ONLINE_USERS.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(messageObj)));
            } catch (IOException ignored) {
            }
        }
    }
}
