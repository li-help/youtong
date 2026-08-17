package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Activity;
import com.youtong.service.ActivityService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/activity")
public class ActivityController extends CrudController<Activity, Long> {
    private final ActivityService activityService;

    public ActivityController(ActivityService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"title"}, "activity", dataVersionService);
        this.activityService = service;
    }

    /** C 端活动列表（公开，仅进行中 status=1） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<Activity> p = new Page<>(page, pageSize);
        QueryWrapper<Activity> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("start_time");
        p = activityService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
