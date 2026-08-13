package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Ad;
import com.youtong.service.AdService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ad")
public class AdController extends CrudController<Ad, Long> {
    public AdController(AdService service) {
        super(service, "status", new String[]{"title", "url"});
    }
}
