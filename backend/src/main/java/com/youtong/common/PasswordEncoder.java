package com.youtong.common;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * BCrypt 密码工具：注册/改密时 encode，登录时 matches。
 * 全局复用同一个 BCryptPasswordEncoder 实例。
 */
public class PasswordEncoder {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    /** 加密明文密码 */
    public static String encode(String rawPassword) {
        return ENCODER.encode(rawPassword);
    }

    /** 校验明文与库中密文是否匹配 */
    public static boolean matches(String rawPassword, String encodedPassword) {
        if (rawPassword == null || encodedPassword == null) {
            return false;
        }
        return ENCODER.matches(rawPassword, encodedPassword);
    }

    /** 判断字符串是否已是 BCrypt 密文（用于避免重复加密） */
    public static boolean isEncoded(String password) {
        return password != null && password.startsWith("$2a$");
    }
}
