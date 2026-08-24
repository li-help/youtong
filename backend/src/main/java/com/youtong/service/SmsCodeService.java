package com.youtong.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 短信验证码服务（内存存储 + 阿里云短信下发）。
 *
 * 发送时：生成验证码存入内存（用于后续 verify 校验），同时调用阿里云短信下发到用户手机。
 * 若阿里云未配置（开发联调），自动降级为「演示模式」并直接返回明文验证码，便于本地调试。
 */
@Service
public class SmsCodeService {

    /** 验证码有效期：5 分钟 */
    public static final long EXPIRE_MS = 5 * 60 * 1000L;

    @Autowired(required = false)
    private AliyunSmsService aliyunSmsService;

    private static class SmsCode {
        String code;
        long expireAt;

        SmsCode(String code) {
            this.code = code;
            this.expireAt = System.currentTimeMillis() + EXPIRE_MS;
        }
    }

    private final Map<String, SmsCode> store = new ConcurrentHashMap<>();

    /**
     * 发送验证码到指定手机号。
     *
     * @return 验证码明文（仅当阿里云未配置、降级为演示模式时返回；正式环境返回 null，验证码通过短信下发）
     */
    public String send(String phone) {
        String code = String.format("%06d", ThreadLocalRandom.current().nextInt(1000000));
        store.put(phone, new SmsCode(code));
        if (aliyunSmsService != null) {
            try {
                aliyunSmsService.sendCode(phone, code);
                return null; // 正式下发，不返回明文
            } catch (Exception e) {
                // 发送失败：开发阶段降级为返回明文，方便联调；生产环境应改为抛异常
                return code;
            }
        }
        return code; // 未配置阿里云，演示模式
    }

    /**
     * 校验验证码（一次性：无论成功与否均移除，防止重放）。
     */
    public boolean verify(String phone, String code) {
        if (phone == null || code == null) {
            return false;
        }
        SmsCode smsCode = store.remove(phone);
        if (smsCode == null) {
            return false;
        }
        if (System.currentTimeMillis() > smsCode.expireAt) {
            return false;
        }
        return smsCode.code.equals(code.trim());
    }

    /** 清理过期的验证码（可定时调用，演示环境非必须） */
    public void cleanExpired() {
        long now = System.currentTimeMillis();
        store.entrySet().removeIf(e -> now > e.getValue().expireAt);
    }
}
