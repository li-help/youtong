package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.common.JwtUtil;
import com.youtong.common.R;
import com.youtong.entity.CustomerService;
import com.youtong.entity.ImMessage;
import com.youtong.entity.ImSession;
import com.youtong.entity.SysAccount;
import com.youtong.service.CustomerServiceService;
import com.youtong.service.ImMessageService;
import com.youtong.service.ImSessionService;
import com.youtong.service.SysAccountService;
import com.youtong.websocket.ImWebSocketHandler;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/im")
public class ImController {

    @Autowired
    private ImSessionService sessionService;

    @Autowired
    private ImMessageService messageService;

    @Autowired
    private SysAccountService accountService;

    @Autowired
    private CustomerServiceService customerServiceService;

    @Autowired
    private ImWebSocketHandler webSocketHandler;

    private SysAccount getCurrentUser(HttpServletRequest request) {
        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) return null;
        String token = auth.substring(7);
        String username = JwtUtil.getUsername(token);
        if (username == null) return null;
        return accountService.getOne(new QueryWrapper<SysAccount>().eq("username", username));
    }

    /**
     * 获取当前用户的会话列表
     */
    @GetMapping("/session/list")
    public R listSessions(HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        QueryWrapper<ImSession> qw = new QueryWrapper<>();
        if ("admin".equalsIgnoreCase(user.getRole()) || "operator".equalsIgnoreCase(user.getRole())) {
            // 客服/管理员：查询所有会话，或所属客服会话
            qw.orderByDesc("updated_at");
        } else {
            // 普通用户：查询自己的会话
            qw.eq("user_id", user.getId()).orderByDesc("updated_at");
        }

        List<ImSession> list = sessionService.list(qw);
        sessionService.fillSessionExtra(list);
        return R.ok(list);
    }

    /**
     * 初始化/获取会话
     */
    @GetMapping("/session/init")
    public R initSession(@RequestParam(defaultValue = "0") Long storeId, HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        ImSession session = sessionService.getOrCreateSession(user.getId(), storeId);
        sessionService.fillSessionExtra(List.of(session));
        return R.ok(session);
    }

    /**
     * 获取历史消息记录
     */
    @GetMapping("/message/history")
    public R messageHistory(@RequestParam Long sessionId,
                           @RequestParam(defaultValue = "1") Integer page,
                           @RequestParam(defaultValue = "30") Integer pageSize,
                           HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        List<ImMessage> messages = messageService.getHistory(sessionId, page, pageSize);
        // 自动标记已读
        messageService.markAsRead(sessionId, user.getId());
        return R.ok(messages);
    }

    /**
     * 标记已读
     */
    @PostMapping("/message/read")
    public R markRead(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        Long sessionId = body.get("sessionId") != null ? Long.valueOf(body.get("sessionId").toString()) : null;
        if (sessionId != null) {
            messageService.markAsRead(sessionId, user.getId());
        }
        return R.ok();
    }

    /**
     * AI 会话无缝转人工客服
     */
    @PostMapping("/session/transfer")
    public R transferToHuman(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        Long sessionId = body.get("sessionId") != null ? Long.valueOf(body.get("sessionId").toString()) : null;
        if (sessionId == null) return R.fail("缺少会话ID");

        ImSession session = sessionService.getById(sessionId);
        if (session == null) return R.fail("会话不存在");

        // 1. 寻找匹配的在线客服（优先该店铺，其次全局客服）
        CustomerService cs = customerServiceService.getOne(new QueryWrapper<CustomerService>()
                .eq(session.getStoreId() != null && session.getStoreId() > 0, "store_id", session.getStoreId())
                .eq("status", 1)
                .orderByDesc("online")
                .last("LIMIT 1"));

        session.setSessionType(2); // 切换为人工模式
        if (cs != null) {
            session.setCsId(cs.getId());
        }
        sessionService.updateById(session);

        // 2. 生成系统转接通知消息
        String tip = (cs != null && cs.getOnline() == 1)
                ? "【系统提示】已为您转接在线人工客服【" + cs.getName() + "】，请直接输入您的问题。"
                : "【系统提示】已为您转接人工客服。当前客服离线中，您可以直接留言，我们上线后将第一时间回复。";

        ImMessage noticeMsg = messageService.saveMessage(session.getId(), UUID.randomUUID().toString(), 4, 0L, user.getId(), "transfer_notice", tip);

        // 3. WebSocket 实时通知客服与用户
        Map<String, Object> wsMsg = new HashMap<>();
        wsMsg.put("type", "transfer");
        wsMsg.put("sessionId", session.getId());
        wsMsg.put("sessionType", 2);
        wsMsg.put("message", noticeMsg);

        webSocketHandler.sendToUser(user.getId(), wsMsg);
        if (cs != null && cs.getAccountId() != null) {
            webSocketHandler.sendToUser(cs.getAccountId(), wsMsg);
        }

        Map<String, Object> res = new HashMap<>();
        res.put("sessionType", 2);
        res.put("cs", cs);
        res.put("notice", tip);
        return R.ok(res);
    }
}
