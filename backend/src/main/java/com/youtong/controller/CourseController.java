package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Course;
import com.youtong.service.CourseService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/course")
public class CourseController extends CrudController<Course, Long> {
    public CourseController(CourseService service) {
        super(service, "status", new String[]{"title", "teacher"});
    }
}
