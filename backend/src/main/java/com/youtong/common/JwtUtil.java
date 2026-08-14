package com.youtong.common;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * 轻量 JWT 工具（HS256，纯 JDK 实现，不依赖第三方 JWT 库）。
 * 仅用于后台管理系统演示级鉴权，密钥请在生产环境替换为强随机值并外部配置。
 */
public class JwtUtil {

    /** 签名密钥（优先从环境变量 JWT_SECRET 读取，否则使用默认演示值；生产环境务必外部配置） */
    private static final String SECRET = System.getenv().getOrDefault("JWT_SECRET", "youtong-admin-secret-key-2026-please-change-me");
    /** 过期时间：2 小时 */
    public static final long EXPIRE_MS = 2 * 60 * 60 * 1000L;

    private static String base64UrlEncode(byte[] bytes) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static byte[] base64UrlDecode(String s) {
        return Base64.getUrlDecoder().decode(s);
    }

    /** 生成 HS256 签名 */
    private static String sign(String headerAndPayload) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        return base64UrlEncode(mac.doFinal(headerAndPayload.getBytes(StandardCharsets.UTF_8)));
    }

    /** 签发 token：携带 sub(用户名)、role、exp */
    public static String generate(String username, String role) {
        try {
            long now = System.currentTimeMillis();
            Map<String, Object> header = new HashMap<>();
            header.put("alg", "HS256");
            header.put("typ", "JWT");
            Map<String, Object> payload = new HashMap<>();
            payload.put("sub", username);
            payload.put("role", role);
            payload.put("iat", now / 1000);
            payload.put("exp", (now + EXPIRE_MS) / 1000);

            String headerJson = toJson(header);
            String payloadJson = toJson(payload);
            String h = base64UrlEncode(headerJson.getBytes(StandardCharsets.UTF_8));
            String p = base64UrlEncode(payloadJson.getBytes(StandardCharsets.UTF_8));
            String signingInput = h + "." + p;
            return signingInput + "." + sign(signingInput);
        } catch (Exception e) {
            throw new RuntimeException("生成 token 失败", e);
        }
    }

    /** 校验并解析 token，失败返回 null */
    public static Map<String, Object> parse(String token) {
        if (token == null || token.trim().isEmpty()) return null;
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) return null;
            String signingInput = parts[0] + "." + parts[1];
            if (!sign(signingInput).equals(parts[2])) return null;

            String payloadJson = new String(base64UrlDecode(parts[1]), StandardCharsets.UTF_8);
            Map<String, Object> payload = fromJson(payloadJson);
            long exp = ((Number) payload.get("exp")).longValue();
            if (exp * 1000L < System.currentTimeMillis()) return null;
            return payload;
        } catch (Exception e) {
            return null;
        }
    }

    public static String getUsername(String token) {
        Map<String, Object> c = parse(token);
        return c == null ? null : (String) c.get("sub");
    }

    private static String toJson(Map<String, Object> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> e : map.entrySet()) {
            if (!first) sb.append(",");
            first = false;
            sb.append("\"").append(e.getKey()).append("\":");
            Object v = e.getValue();
            if (v instanceof Number) sb.append(v);
            else if (v instanceof String) sb.append("\"").append(v).append("\"");
            else sb.append("\"").append(v).append("\"");
        }
        sb.append("}");
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> fromJson(String json) {
        // 简单解析：本工具仅写入已知字段，采用轻量解析
        Map<String, Object> map = new HashMap<>();
        String body = json.trim();
        if (body.startsWith("{")) body = body.substring(1);
        if (body.endsWith("}")) body = body.substring(0, body.length() - 1);
        for (String pair : body.split(",")) {
            String[] kv = pair.split(":", 2);
            if (kv.length != 2) continue;
            String k = stripQuotes(kv[0].trim());
            String rawV = kv[1].trim();
            if (rawV.startsWith("\"") && rawV.endsWith("\"")) {
                map.put(k, stripQuotes(rawV));
            } else {
                try {
                    map.put(k, Long.parseLong(rawV));
                } catch (NumberFormatException ex) {
                    map.put(k, rawV);
                }
            }
        }
        return map;
    }

    private static String stripQuotes(String s) {
        if (s.length() >= 2 && s.startsWith("\"") && s.endsWith("\"")) {
            return s.substring(1, s.length() - 1);
        }
        return s;
    }
}
