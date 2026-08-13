package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Activity;
import com.youtong.service.ActivityService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/activity")
public class ActivityController extends CrudController<Activity, Long> {
    public ActivityController(ActivityService service) {
        super(service, "status", new String[]{"title"});
    }
}
