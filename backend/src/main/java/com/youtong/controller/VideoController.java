package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Video;
import com.youtong.service.VideoService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/video")
public class VideoController extends CrudController<Video, Long> {
    public VideoController(VideoService service) {
        super(service, "status", new String[]{"title"});
    }
}
