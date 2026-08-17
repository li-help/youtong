package com.youtong.controller;

import com.youtong.common.R;
import com.youtong.service.DataVersionService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.BlockingQueue;

/**
 * 通用实时同步接口（C 端公开，白名单放行 /api/sync/**）：
 *  - GET /api/sync/version?channel=xxx   轻量轮询该频道当前版本号（跨端通用，小程序/App/H5 均可用）
 *  - GET /api/sync/stream?channel=xxx     SSE 实时推送该频道版本号变化（H5 / App 可用）
 */
@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final DataVersionService dataVersionService;

    public SyncController(DataVersionService dataVersionService) {
        this.dataVersionService = dataVersionService;
    }

    @GetMapping("/version")
    public R version(@RequestParam String channel) {
        return R.ok(dataVersionService.getVersion(channel));
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@RequestParam String channel) {
        SseEmitter emitter = new SseEmitter(0L); // 0 = 不超时
        BlockingQueue<Long> queue = dataVersionService.subscribe(channel);

        // 先推送当前版本号，确保新连接立即拿到基准值
        try {
            emitter.send(SseEmitter.event().name("version").data(dataVersionService.getVersion(channel)));
        } catch (IOException e) {
            emitter.completeWithError(e);
            return emitter;
        }

        Thread worker = new Thread(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    Long v = queue.take();
                    emitter.send(SseEmitter.event().name("version").data(v));
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } catch (IOException e) {
                // 客户端断开
            } finally {
                dataVersionService.unsubscribe(channel, queue);
                emitter.complete();
            }
        });
        worker.setDaemon(true);
        worker.start();

        emitter.onCompletion(() -> {
            dataVersionService.unsubscribe(channel, queue);
            worker.interrupt();
        });
        emitter.onTimeout(() -> {
            dataVersionService.unsubscribe(channel, queue);
            worker.interrupt();
        });
        return emitter;
    }
}
