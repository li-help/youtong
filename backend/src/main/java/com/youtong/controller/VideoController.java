package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Video;
import com.youtong.service.VideoService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/video")
public class VideoController extends CrudController<Video, Long> {
    private final VideoService videoService;

    public VideoController(VideoService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"title"}, "video", dataVersionService);
        this.videoService = service;
    }

    /** C 端视频列表（公开，仅上线 status=1） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<Video> p = new Page<>(page, pageSize);
        QueryWrapper<Video> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("id");
        p = videoService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
