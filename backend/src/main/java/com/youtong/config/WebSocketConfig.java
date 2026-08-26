package com.youtong.config;

import com.youtong.websocket.ImHandshakeInterceptor;
import com.youtong.websocket.ImWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private ImWebSocketHandler imWebSocketHandler;

    @Autowired
    private ImHandshakeInterceptor imHandshakeInterceptor;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(imWebSocketHandler, "/ws/im")
                .addInterceptors(imHandshakeInterceptor)
                .setAllowedOriginPatterns("*");
    }
}
