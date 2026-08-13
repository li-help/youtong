package com.youtong.controller;

import com.youtong.common.R;
import com.youtong.entity.Ad;
import com.youtong.service.AdService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/banner")
public class BannerController {

    private final AdService adService;

    public BannerController(AdService adService) {
        this.adService = adService;
    }

    /** C 端公开接口：按广告位编码返回启用中的广告（免鉴权，白名单放行） */
    @GetMapping("/{code}")
    public R position(@PathVariable String code) {
        List<Ad> list = adService.listByPositionCode(code);
        return R.ok(list);
    }
}
