package com.youtong.common;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 扫码登录状态管理器（内存实现，演示用）
 * 真实生产环境应改为 Redis 存储并支持过期清理。
 */
@Component
public class ScanLoginManager {

    public static final String STATUS_WAITING = "waiting";   // 待扫码
    public static final String STATUS_SCANNED = "scanned";    // 已扫码，待确认
    public static final String STATUS_CONFIRMED = "confirmed"; // 已确认，可登录
    public static final long EXPIRE_MS = 5 * 60 * 1000L;       // 5 分钟过期

    private static class TicketInfo {
        String status;
        long createTime;
        String token;   // 确认后写入登录 token
        String openid;  // 确认时绑定的 openid/用户标识

        TicketInfo(String status) {
            this.status = status;
            this.createTime = System.currentTimeMillis();
        }
    }

    private final Map<String, TicketInfo> tickets = new ConcurrentHashMap<>();

    public String create() {
        String ticket = "SCAN_" + System.nanoTime() + "_" + (int) (Math.random() * 100000);
        tickets.put(ticket, new TicketInfo(STATUS_WAITING));
        return ticket;
    }

    /** 标记已扫码（手机端扫码触发） */
    public boolean markScanned(String ticket) {
        TicketInfo info = tickets.get(ticket);
        if (info == null || isExpired(info)) {
            return false;
        }
        info.status = STATUS_SCANNED;
        return true;
    }

    /** 确认登录，写入 token（真实环境由微信 OAuth 回调/手机端确认触发） */
    public boolean confirm(String ticket, String token, String openid) {
        TicketInfo info = tickets.get(ticket);
        if (info == null || isExpired(info)) {
            return false;
        }
        info.status = STATUS_CONFIRMED;
        info.token = token;
        info.openid = openid;
        return true;
    }

    /** PC 端轮询：返回当前状态、是否已过期，确认后附带 token */
    public Map<String, Object> check(String ticket) {
        TicketInfo info = tickets.get(ticket);
        Map<String, Object> res = new java.util.HashMap<>();
        if (info == null) {
            res.put("status", "not_found");
            return res;
        }
        if (isExpired(info)) {
            tickets.remove(ticket);
            res.put("status", "expired");
            return res;
        }
        res.put("status", info.status);
        if (STATUS_CONFIRMED.equals(info.status) && info.token != null) {
            res.put("token", info.token);
        }
        return res;
    }

    /** 删除 ticket（创建后预检失败时回滚） */
    public void remove(String ticket) {
        tickets.remove(ticket);
    }

    private boolean isExpired(TicketInfo info) {
        return System.currentTimeMillis() - info.createTime > EXPIRE_MS;
    }
}
