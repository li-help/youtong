package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.CustomerService;
import com.youtong.service.CustomerServiceService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/service")
public class ServiceController extends CrudController<CustomerService, Long> {
    private final CustomerServiceService serviceService;

    public ServiceController(CustomerServiceService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"name", "phone"}, "service", dataVersionService);
        this.serviceService = service;
    }

    /** C 端服务列表（公开） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<CustomerService> p = new Page<>(page, pageSize);
        QueryWrapper<CustomerService> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("id");
        p = serviceService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
