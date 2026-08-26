package com.youtong.websocket;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.common.JwtUtil;
import com.youtong.entity.CustomerService;
import com.youtong.entity.SysAccount;
import com.youtong.service.CustomerServiceService;
import com.youtong.service.SysAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket 握手拦截器：从 query 参数解析 token 进行 JWT 鉴权
 */
@Component
public class ImHandshakeInterceptor implements HandshakeInterceptor {

    @Autowired
    private SysAccountService accountService;

    @Autowired
    private CustomerServiceService customerServiceService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                  WebSocketHandler wsHandler, Map<String, Object> attributes) {
        try {
            if (request instanceof ServletServerHttpRequest servletRequest) {
                String token = servletRequest.getServletRequest().getParameter("token");
                if (token == null || token.isBlank()) {
                    String auth = servletRequest.getServletRequest().getHeader("Authorization");
                    if (auth != null && auth.startsWith("Bearer ")) {
                        token = auth.substring(7);
                    }
                }
                if (token != null && !token.isBlank()) {
                    Map<String, Object> claims = JwtUtil.parse(token);
                    if (claims != null) {
                        String username = (String) claims.get("sub");
                        try {
                            SysAccount account = accountService.getOne(
                                    new QueryWrapper<SysAccount>().eq("username", username));
                            if (account != null) {
                                attributes.put("userId", account.getId());
                                attributes.put("username", username);
                                attributes.put("role", account.getRole());

                                // 若是客服角色，关联 customer_service.id
                                try {
                                    CustomerService cs = customerServiceService.getOne(
                                            new QueryWrapper<CustomerService>().eq("account_id", account.getId()));
                                    if (cs != null) {
                                        attributes.put("csId", cs.getId());
                                        attributes.put("storeId", cs.getStoreId());
                                    }
                                } catch (Exception ignored) {
                                }
                            }
                        } catch (Exception ignored) {
                        }
                    }
                }
            }
        } catch (Exception ignored) {
        }
        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
    }
}
