package com.youtong.service;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 通用数据版本号服务（按“频道”维度维护）。
 *
 * 后台对各业务模块（广告 / 课程 / 门店 / 服务 / 活动 / 视频 / 文章 / 分类）做增删改时，
 * 对应频道版本号自增；C 端通过轻量轮询版本号或 SSE 监听变更，实现“后台改数据，前端实时刷新”。
 *
 * 采用纯 JUC 实现，不依赖 WebFlux / Reactor，兼容当前 Spring Boot MVC 工程。
 */
@Service
public class DataVersionService {

    /** 每个频道一个版本号（以时间戳初始化，保证进程重启后旧端能感知到变化） */
    private final Map<String, AtomicLong> versions = new ConcurrentHashMap<>();
    /** 每个频道一组 SSE 订阅队列 */
    private final Map<String, CopyOnWriteArrayList<BlockingQueue<Long>>> subscribers = new ConcurrentHashMap<>();

    /** 频道发生变更时调用：版本号自增并唤醒该频道所有 SSE 订阅者 */
    public long increment(String channel) {
        long v = versions.computeIfAbsent(channel, k -> new AtomicLong(System.currentTimeMillis())).incrementAndGet();
        CopyOnWriteArrayList<BlockingQueue<Long>> subs = subscribers.get(channel);
        if (subs != null) {
            for (BlockingQueue<Long> q : subs) {
                q.offer(v);
            }
        }
        return v;
    }

    /** 读取某频道当前版本号（轻量轮询接口使用） */
    public long getVersion(String channel) {
        AtomicLong v = versions.get(channel);
        return v == null ? 0L : v.get();
    }

    /** 注册某频道的 SSE 订阅者，返回其专属队列；连接关闭时调用 {@link #unsubscribe} */
    public BlockingQueue<Long> subscribe(String channel) {
        BlockingQueue<Long> q = new LinkedBlockingQueue<>();
        subscribers.computeIfAbsent(channel, k -> new CopyOnWriteArrayList<>()).add(q);
        return q;
    }

    /** 取消某频道的 SSE 订阅 */
    public void unsubscribe(String channel, BlockingQueue<Long> q) {
        CopyOnWriteArrayList<BlockingQueue<Long>> subs = subscribers.get(channel);
        if (subs != null) subs.remove(q);
    }
}
