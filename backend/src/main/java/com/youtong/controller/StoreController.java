package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Store;
import com.youtong.service.StoreService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/store")
public class StoreController extends CrudController<Store, Long> {
    private final StoreService storeService;

    public StoreController(StoreService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"name", "address"}, "store", dataVersionService);
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

    /**
     * C 端附近门店列表（带距离计算与由近及远排序）
     */
    @GetMapping("/nearby")
    public R nearby(@RequestParam(required = false) Double lat,
                    @RequestParam(required = false) Double lng,
                    @RequestParam(required = false) String keyword) {
        QueryWrapper<Store> qw = new QueryWrapper<>();
        qw.eq("status", 1);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like("name", keyword.trim()).or().like("address", keyword.trim()));
        }

        java.util.List<Store> stores = storeService.list(qw);

        if (lat != null && lng != null) {
            for (Store s : stores) {
                if (s.getLat() != null && s.getLng() != null) {
                    double dist = calculateDistance(lat, lng, s.getLat().doubleValue(), s.getLng().doubleValue());
                    s.setDistance(Math.round(dist * 100.0) / 100.0); // 保留两位小数
                } else {
                    s.setDistance(99999.0);
                }
            }
            stores.sort(java.util.Comparator.comparing(Store::getDistance));
        } else {
            stores.sort(java.util.Comparator.comparing(Store::getScore, java.util.Comparator.nullsLast(java.util.Comparator.reverseOrder())));
        }

        return R.ok(stores);
    }

    /**
     * Haversine 球面大圆距离公式（返回千米）
     */
    private double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
        final int R = 6371; // 地球半径 (km)
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lng2 - lng1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
