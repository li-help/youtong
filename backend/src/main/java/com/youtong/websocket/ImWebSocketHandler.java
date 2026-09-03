package com.youtong.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.entity.CustomerService;
import com.youtong.entity.ImMessage;
import com.youtong.entity.ImSession;
import com.youtong.service.CustomerServiceService;
import com.youtong.service.ImMessageService;
import com.youtong.service.ImSessionService;import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
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

    @Autowired
    private CustomerServiceService customerServiceService;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            ONLINE_USERS.put(userId, session);
            syncCsOnline(userId, 1);
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

                // 计算接收方：显式 receiverId 优先；否则按会话自动路由
                // - 客服发言 -> 会话用户
                // - 人工会话中的用户发言 -> 会话绑定的客服（店铺客服/官方客服）账号
                Set<Long> targets = new HashSet<>();
                if (receiverId != null && receiverId > 0) {
                    targets.add(receiverId);
                } else {
                    ImSession imSession = sessionService.getById(sessionId);
                    if (imSession != null) {
                        if (senderType != null && senderType == 2) {
                            if (imSession.getUserId() != null) {
                                targets.add(imSession.getUserId());
                            }
                        } else if (imSession.getSessionType() != null && imSession.getSessionType() == 2
                                && imSession.getCsId() != null) {
                            CustomerService cs = customerServiceService.getById(imSession.getCsId());
                            if (cs != null && cs.getAccountId() != null) {
                                targets.add(cs.getAccountId());
                            }
                        }
                    }
                }
                targets.remove(senderId);

                // 转发给接收方（如果在线）
                Map<String, Object> forward = Map.of("type", "chat", "message", saved);
                String forwardPayload = objectMapper.writeValueAsString(forward);
                for (Long targetId : targets) {
                    WebSocketSession targetSession = ONLINE_USERS.get(targetId);
                    if (targetSession != null && targetSession.isOpen()) {
                        try {
                            targetSession.sendMessage(new TextMessage(forwardPayload));
                        } catch (IOException ignored) {
                        }
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
            syncCsOnline(userId, 0);
        }
    }

    /**
     * 指定账号是否持有活跃 WebSocket 连接（真实在线）
     */
    public boolean isUserOnline(Long userId) {
        if (userId == null) return false;
        WebSocketSession s = ONLINE_USERS.get(userId);
        return s != null && s.isOpen();
    }

    /**
     * 客服账号 WebSocket 上下线时，同步 customer_service.online 标记，
     * 使后台配置的“在线”开关与真实在线状态保持一致
     */
    private void syncCsOnline(Long accountId, Integer online) {
        try {
            CustomerService cs = customerServiceService.getOne(
                    new QueryWrapper<CustomerService>().eq("account_id", accountId).last("LIMIT 1"));
            if (cs != null && !online.equals(cs.getOnline())) {
                cs.setOnline(online);
                customerServiceService.updateById(cs);
            }
        } catch (Exception ignored) {
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
