package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.AdPosition;
import com.youtong.service.AdPositionService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ad/position")
public class AdPositionController extends CrudController<AdPosition, Long> {
    public AdPositionController(AdPositionService service) {
        super(service, "status", new String[]{"name", "code"});
    }
}
