package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.youtong.common.PageQuery;
import com.youtong.common.R;
import com.youtong.entity.Order;
import com.youtong.entity.SysAccount;
import com.youtong.service.OrderService;
import com.youtong.service.SysAccountService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    private static final String[] STATUS_TEXT = {"待支付", "已支付", "已核销", "已取消"};
    private final OrderService service;
    private final SysAccountService accountService;

    public OrderController(OrderService service, SysAccountService accountService) {
        this.service = service;
        this.accountService = accountService;
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

    @PostMapping
    public R save(@RequestBody Order entity) {
        service.saveOrUpdate(entity);
        return R.ok();
    }

    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");

    @PostMapping("/create")
    public R create(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        String err = validateOrderBody(body);
        if (err != null) return R.fail(err);

        Order o = new Order();
        o.setOrderNo(generateOrderNo());
        if (body.get("courseId") != null) {
            o.setCourseId(Long.valueOf(body.get("courseId").toString()));
        }
        o.setCourseName(body.get("courseName").toString());
        o.setAmount(parseAmount(body.get("price")));
        o.setContactName(body.get("contactName").toString());
        o.setContactPhone(body.get("contactPhone").toString());
        o.setAgeRange(body.get("ageRange") == null ? null : body.get("ageRange").toString());
        o.setRemark(body.get("remark") == null ? null : body.get("remark").toString());
        o.setStatus(0);
        bindCurrentUser(o, request);
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        o.setCreatedAt(now);
        o.setUpdatedAt(now);
        service.save(o);
        fillText(o);
        return R.ok(o);
    }

    private String validateOrderBody(Map<String, Object> body) {
        if (isBlank(body.get("courseName"))) return "课程名称不能为空";
        if (isBlank(body.get("contactName"))) return "联系人姓名不能为空";
        if (isBlank(body.get("contactPhone"))) return "联系人电话不能为空";
        String phone = body.get("contactPhone").toString().trim();
        if (!PHONE_PATTERN.matcher(phone).matches()) return "请输入有效的手机号";
        if (parseAmount(body.get("price")).compareTo(BigDecimal.ZERO) < 0) return "订单金额不能为负数";
        return null;
    }

    private boolean isBlank(Object v) {
        return v == null || v.toString().trim().isEmpty();
    }

    private BigDecimal parseAmount(Object v) {
        if (v == null) return BigDecimal.ZERO;
        try {
            return new BigDecimal(v.toString().trim());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private void bindCurrentUser(Order o, HttpServletRequest request) {
        Object username = request.getAttribute("username");
        if (username != null) {
            SysAccount account = accountService.getOne(
                    new QueryWrapper<SysAccount>().eq("username", username.toString()).last("LIMIT 1"));
            if (account != null) {
                o.setUserId(account.getId());
            }
        }
    }

    private String generateOrderNo() {
        return "YT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%06d", ThreadLocalRandom.current().nextInt(1000000))
                + String.format("%03d", Math.abs(System.nanoTime() % 1000));
    }

    @DeleteMapping("/{id}")
    public R remove(@PathVariable Long id) {
        service.removeById(id);
        return R.ok();
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
