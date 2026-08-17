package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.PageQuery;
import com.youtong.common.R;
import com.youtong.entity.Ad;
import com.youtong.service.AdService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/ad")
public class AdController extends CrudController<Ad, Long> {
    private final AdService adService;

    public AdController(AdService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"title", "url"}, "banner", dataVersionService, true);
        this.adService = service;
    }

    /** C 端轮播广告（公开）：按广告位 + 启用状态 + 生效时间过滤，按 sort 排序 */
    @GetMapping("/list")
    public R bannerList(@RequestParam(defaultValue = "1") Long positionId,
                        @RequestParam(required = false) Integer status,
                        @RequestParam(defaultValue = "1") Integer page,
                        @RequestParam(defaultValue = "20") Integer pageSize) {
        Page<Ad> p = new Page<>(page, pageSize);
        QueryWrapper<Ad> qw = new QueryWrapper<>();
        qw.eq("position_id", positionId);
        if (status != null) qw.eq("status", status);
        LocalDateTime now = LocalDateTime.now();
        qw.and(w -> w.isNull("start_time").or().le("start_time", now));
        qw.and(w -> w.isNull("end_time").or().ge("end_time", now));
        qw.orderByAsc("sort").orderByAsc("id");
        p = adService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
