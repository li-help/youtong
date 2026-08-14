package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Store;
import com.youtong.service.StoreService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/store")
public class StoreController extends CrudController<Store, Long> {
    private final StoreService storeService;

    public StoreController(StoreService service) {
        super(service, "status", new String[]{"name", "address"});
        this.storeService = service;
    }

    /** C 端门店列表（公开） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<Store> p = new Page<>(page, pageSize);
        QueryWrapper<Store> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("score");
        p = storeService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
