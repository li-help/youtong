package com.youtong.common;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 鉴权拦截器：除白名单外，所有 /api/** 请求需携带合法 Authorization: Bearer <token>
 */
@Component
public class JwtInterceptor implements HandlerInterceptor {

    /** 无需鉴权的接口；支持两种写法：
     *  1) 普通路径："/api/xxx" 或 "/api/xxx/*"（末尾 * 为前缀匹配，不区分方法）
     *  2) 限定方法：前缀 "METHOD:" 表示仅对指定 HTTP 方法放行，如 "GET:/api/course/*"
     */
    private static final String[] WHITE_LIST = {
            "/api/auth/login",
            "/api/auth/phoneLogin",
            "/api/auth/register",
            "/api/auth/sendCode",
            "/api/auth/checkCode",
            "/api/auth/resetPwdByCode",
            "/api/auth/wechatLogin",
            "/api/auth/scanLogin/create",
            "/api/auth/scanLogin/check",
            "/api/auth/scanLogin/confirm",
            "/api/auth/scanLogin/marked",
            "/api/auth/scanLogin/wxacode/*",
            "/api/auth/qrcode/*",
            "/api/auth/logout",
            "/api/ad/position/*",
            "GET:/api/ad/*",
            "GET:/api/ad",
            "GET:/api/ad/list",
            "POST:/api/ad",
            "DELETE:/api/ad/*",
            "/api/course/recommend",
            "/api/course/list",
            "GET:/api/course/*",
            "/api/article/published",
            "/api/article/view/*",
            "GET:/api/store/*",
            "/api/store/list",
            "/api/service/list",
            "GET:/api/service/*",
            "GET:/api/user/qrcode/*",
            "GET:/api/video/*",
            "GET:/api/activity/*",
            "GET:/api/video/list",
            "GET:/api/activity/list",
            "GET:/api/category/list",
            "GET:/api/category/*",
            "/api/ai/**",
            "/api/sync/*",
            "GET:/api/faq/*",
            "/api/faq/hot",
            "/api/faq/list",
            "/api/store/nearby",
    };

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 放行预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String uri = request.getRequestURI();
        String method = request.getMethod();
        for (String w : WHITE_LIST) {
            String needMethod = null;
            String pattern = w;
            if (w.contains(":")) {
                int idx = w.indexOf(':');
                needMethod = w.substring(0, idx);
                pattern = w.substring(idx + 1);
            }
            if (needMethod != null && !needMethod.equalsIgnoreCase(method)) {
                continue;
            }
            if (uri.equals(pattern) || (pattern.endsWith("*") && uri.startsWith(pattern.substring(0, pattern.length() - 1)))) {
                return true;
            }
        }
        String auth = request.getHeader("Authorization");
        String token = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            token = auth.substring(7);
        }
        if (token == null || JwtUtil.parse(token) == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"未登录或登录已过期\",\"data\":null}");
            return false;
        }
        // 将用户名写入请求属性，供后续 Controller 使用
        request.setAttribute("username", JwtUtil.getUsername(token));
        return true;
    }
}
