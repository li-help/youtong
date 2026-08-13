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

    /** 无需鉴权的接口 */
    private static final String[] WHITE_LIST = {
            "/api/auth/login",
            "/api/auth/logout",
    };

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 放行预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String uri = request.getRequestURI();
        for (String w : WHITE_LIST) {
            if (uri.equals(w)) {
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
