package com.youtong;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@MapperScan("com.youtong.mapper")
public class YoutongAdminApplication {
    public static void main(String[] args) {
        SpringApplication.run(YoutongAdminApplication.class, args);
    }
}
