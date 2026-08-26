package com.youtong.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理：捕获未处理的运行时异常，统一返回结构并打印堆栈，便于排查 500 问题。
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public R handleException(Exception e) {
        log.error("系统异常: {}", e.getMessage(), e);
        return R.fail("系统繁忙，请稍后重试: " + e.getMessage());
    }
}
