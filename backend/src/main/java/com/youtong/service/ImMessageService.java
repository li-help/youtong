package com.youtong.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.CustomerService;
import com.youtong.entity.ImMessage;
import com.youtong.entity.SysAccount;
import com.youtong.mapper.ImMessageMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ImMessageService extends ServiceImpl<ImMessageMapper, ImMessage> {

    @Autowired
    private SysAccountService accountService;

    @Autowired
    private CustomerServiceService customerServiceService;

    @Autowired
    private ImSessionService sessionService;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 保存消息（幂等防重）
     */
    public ImMessage saveMessage(Long sessionId, String clientMsgId, Integer senderType, Long senderId,
                                Long receiverId, String msgType, String content) {
        if (clientMsgId != null && !clientMsgId.isBlank()) {
            ImMessage exists = getOne(new QueryWrapper<ImMessage>().eq("client_msg_id", clientMsgId));
            if (exists != null) {
                return exists;
            }
        } else {
            clientMsgId = java.util.UUID.randomUUID().toString();
        }

        ImMessage msg = new ImMessage();
        msg.setSessionId(sessionId);
        msg.setClientMsgId(clientMsgId);
        msg.setSenderType(senderType != null ? senderType : 1);
        msg.setSenderId(senderId != null ? senderId : 0L);
        msg.setReceiverId(receiverId != null ? receiverId : 0L);
        msg.setMsgType(msgType != null ? msgType : "text");
        msg.setContent(content != null ? content : "");
        msg.setIsRead(0);
        msg.setStatus(1); // 发送成功
        String now = LocalDateTime.now().format(FMT);
        msg.setCreatedAt(now);

        save(msg);

        // 同步更新会话最新消息与未读数
        sessionService.updateLastMessage(sessionId, content, now, senderType != null && senderType == 1);

        return msg;
    }

    /**
     * 分页查询历史消息
     */
    public List<ImMessage> getHistory(Long sessionId, Integer page, Integer pageSize) {
        Page<ImMessage> p = new Page<>(page != null ? page : 1, pageSize != null ? pageSize : 20);
        QueryWrapper<ImMessage> qw = new QueryWrapper<>();
        qw.eq("session_id", sessionId).orderByAsc("created_at", "id");
        List<ImMessage> records = page(p, qw).getRecords();
        fillMessageExtra(records);
        return records;
    }

    /**
     * 标记会话下接收方的消息为已读
     */
    public int markAsRead(Long sessionId, Long receiverId) {
        if (sessionId == null || receiverId == null) return 0;
        int count = baseMapper.markReadBySessionAndReceiver(sessionId, receiverId);
        // 清理会话未读数
        var session = sessionService.getById(sessionId);
        if (session != null) {
            if (receiverId.equals(session.getUserId())) {
                session.setUnreadCountUser(0);
            } else {
                session.setUnreadCountCs(0);
            }
            sessionService.updateById(session);
        }
        return count;
    }

    /**
     * 填充消息发送方信息
     */
    public void fillMessageExtra(List<ImMessage> list) {
        if (list == null || list.isEmpty()) return;
        for (ImMessage m : list) {
            if (m.getSenderType() == 1) { // 用户
                SysAccount u = accountService.getById(m.getSenderId());
                if (u != null) {
                    m.setSenderName(u.getNickname() != null && !u.getNickname().isBlank() ? u.getNickname() : u.getUsername());
                    m.setSenderAvatar(u.getAvatar());
                }
            } else if (m.getSenderType() == 2) { // 客服（senderId 存的是工作台账号 sys_account.id，需按 account_id 反查）
                CustomerService cs = customerServiceService.getOne(new QueryWrapper<CustomerService>()
                        .eq("account_id", m.getSenderId()).last("LIMIT 1"));
                if (cs != null) {
                    m.setSenderName(cs.getName());
                    m.setSenderAvatar(cs.getAvatar());
                }
            } else if (m.getSenderType() == 3) { // AI 机器人
                m.setSenderName("AI 智能助手");
            } else { // 系统
                m.setSenderName("系统通知");
            }
        }
    }
}
