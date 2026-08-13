package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.youtong.common.PageQuery;
import com.youtong.common.R;
import com.youtong.entity.Order;
import com.youtong.service.OrderService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    private static final String[] STATUS_TEXT = {"待支付", "已支付", "已核销", "已取消"};
    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    private void fillText(Order o) {
        if (o.getStatus() != null && o.getStatus() >= 0 && o.getStatus() < STATUS_TEXT.length) {
            o.setStatusText(STATUS_TEXT[o.getStatus()]);
        } else {
            o.setStatusText("未知");
        }
    }

    @GetMapping
    public R list(PageQuery q) {
        IPage<Order> page = q.toPage();
        QueryWrapper<Order> qw = new QueryWrapper<>();
        if (q.getStatusInt() != null) qw.eq("status", q.getStatusInt());
        if (q.getKeyword() != null && !q.getKeyword().trim().isEmpty()) {
            qw.like("order_no", q.getKeyword().trim());
        }
        page = service.page(page, qw);
        page.getRecords().forEach(this::fillText);
        return R.ok(R.page(page.getTotal(), page.getRecords(), page.getCurrent(), page.getSize()));
    }

    @PostMapping("/{id}/verify")
    public R verify(@PathVariable Long id) {
        Order o = service.getById(id);
        if (o == null) return R.fail("订单不存在");
        o.setStatus(2);
        o.setVerifyAt(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        service.updateById(o);
        fillText(o);
        return R.ok(o);
    }
}
