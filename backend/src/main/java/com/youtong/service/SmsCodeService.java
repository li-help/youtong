package com.youtong.service;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 短信验证码服务（内存实现）。
 *
 * 说明：当前未接入真实短信服务商，生成的验证码直接返回给调用方，
 * 方便开发联调；接入短信网关后，将 send() 中返回验证码的逻辑替换为
 * 调用短信服务商下发短信即可，无需改动业务代码。
 */
@Service
public class SmsCodeService {

    /** 验证码有效期：5 分钟 */
    public static final long EXPIRE_MS = 5 * 60 * 1000L;

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
     * @return 验证码（演示环境直接返回，便于联调；正式接入短信后此处返回 null 或脱敏提示）
     */
    public String send(String phone) {
        String code = String.format("%06d", ThreadLocalRandom.current().nextInt(1000000));
        store.put(phone, new SmsCode(code));
        return code;
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
