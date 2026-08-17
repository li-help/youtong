package com.youtong.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.Ad;
import com.youtong.entity.AdPosition;
import com.youtong.mapper.AdMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.Serializable;
import java.util.List;

@Service
public class AdService extends ServiceImpl<AdMapper, Ad> {

    @Autowired
    private AdPositionService adPositionService;

    /** 按广告位编码查询启用中的广告，按 sort 升序（C 端首页轮播等场景使用） */
    public List<Ad> listByPositionCode(String code) {
        AdPosition position = adPositionService.getOne(
                new QueryWrapper<AdPosition>().eq("code", code).eq("status", 1), false);
        if (position == null) {
            return List.of();
        }
        return list(new QueryWrapper<Ad>()
                .eq("position_id", position.getId())
                .eq("status", 1)
                .orderByAsc("sort"));
    }
}
