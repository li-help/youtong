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
            // 客服/管理员：店铺客服（绑定账号且配置了所属门店）只能看到本店会话
            CustomerService cs = customerServiceService.getOne(new QueryWrapper<CustomerService>()
                    .eq("account_id", user.getId()).last("LIMIT 1"));
            if (cs != null && cs.getStoreId() != null && cs.getStoreId() > 0) {
                qw.eq("store_id", cs.getStoreId());
            }
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

        // 1. 寻找接待客服：优先本店铺，其次全平台；真实在线（WebSocket 已连接）优先
        List<CustomerService> pool = customerServiceService.list(new QueryWrapper<CustomerService>()
                .eq("status", 1)
                .orderByDesc("online")
                .orderByAsc("id"));
        boolean realOnline = false;
        CustomerService cs = pickCs(pool, session.getStoreId(), true, false);
        if (cs == null) {
            cs = pickCs(pool, session.getStoreId(), false, true);
        }
        if (cs == null) {
            cs = pickCs(pool, session.getStoreId(), false, false);
        }
        if (cs != null) {
            realOnline = cs.getAccountId() != null && webSocketHandler.isUserOnline(cs.getAccountId());
        }

        session.setSessionType(2); // 切换为人工模式
        if (cs != null) {
            session.setCsId(cs.getId());
        }
        sessionService.updateById(session);

        // 2. 生成系统转接通知消息
        String tip;
        if (cs != null && realOnline) {
            tip = "【系统提示】已为您转接在线人工客服【" + cs.getName() + "】，请直接输入您的问题。";
        } else if (cs != null) {
            tip = "【系统提示】已为您转接人工客服【" + cs.getName() + "】。客服当前不在线，您可以直接留言，上线后将第一时间回复您。";
        } else {
            tip = "【系统提示】暂无可用人工客服，您可以直接留言，我们上线后将第一时间回复您。";
        }

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

    /**
     * 从候选客服池中按优先级挑选接待客服
     *
     * @param storeFirst 仅匹配会话所属店铺的客服
     * @param requireReal 仅挑选账号真实在线（WebSocket 已连接）的客服
     */
    private CustomerService pickCs(List<CustomerService> pool, Long storeId,
                                   boolean storeFirst, boolean requireReal) {
        for (CustomerService cs : pool) {
            boolean storeMatch = storeId == null || storeId <= 0 || storeId.equals(cs.getStoreId());
            if (storeFirst && !storeMatch) continue;
            if (requireReal) {
                if (cs.getAccountId() == null || !webSocketHandler.isUserOnline(cs.getAccountId())) continue;
            }
            return cs;
        }
        return null;
    }

    /**
     * 结束人工会话：切回 AI 接待，并通知双方
     */
    @PostMapping("/session/close")
    public R closeSession(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        Long sessionId = body.get("sessionId") != null ? Long.valueOf(body.get("sessionId").toString()) : null;
        if (sessionId == null) return R.fail("缺少会话ID");

        ImSession session = sessionService.getById(sessionId);
        if (session == null) return R.fail("会话不存在");

        Long csAccountId = null;
        if (session.getCsId() != null) {
            CustomerService cs = customerServiceService.getById(session.getCsId());
            if (cs != null) csAccountId = cs.getAccountId();
        }

        session.setSessionType(1); // 切回 AI 接待
        session.setCsId(null);
        sessionService.updateById(session);

        String tip = "【系统提示】人工服务已结束，已为您切回 AI 智能助手。欢迎对本次服务进行评价，如需人工请再次转接。";
        ImMessage noticeMsg = messageService.saveMessage(session.getId(), UUID.randomUUID().toString(),
                4, 0L, session.getUserId(), "close_notice", tip);

        Map<String, Object> wsMsg = new HashMap<>();
        wsMsg.put("type", "session_close");
        wsMsg.put("sessionId", session.getId());
        wsMsg.put("sessionType", 1);
        wsMsg.put("message", noticeMsg);
        webSocketHandler.sendToUser(session.getUserId(), wsMsg);
        if (csAccountId != null) {
            webSocketHandler.sendToUser(csAccountId, wsMsg);
        }
        return R.ok(Map.of("sessionType", 1, "notice", tip));
    }

    /**
     * 会话满意度评价（1-5 分，用户提交）
     */
    @PostMapping("/session/rate")
    public R rateSession(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        SysAccount user = getCurrentUser(request);
        if (user == null) return R.fail("未登录");

        Long sessionId = body.get("sessionId") != null ? Long.valueOf(body.get("sessionId").toString()) : null;
        Integer score = body.get("score") != null ? Integer.valueOf(body.get("score").toString()) : null;
        if (sessionId == null || score == null || score < 1 || score > 5) {
            return R.fail("评分需为 1-5 的整数");
        }
        ImSession session = sessionService.getById(sessionId);
        if (session == null) return R.fail("会话不存在");
        if (!user.getId().equals(session.getUserId())) return R.fail("只能评价自己的会话");

        session.setRating(score);
        sessionService.updateById(session);

        // 系统消息落库，客服端可见评价结果
        messageService.saveMessage(session.getId(), UUID.randomUUID().toString(),
                4, 0L, session.getUserId(), "rate_notice", "【系统提示】用户对本次服务评价：" + score + " 星。");
        return R.ok(Map.of("rating", score));
    }
}
