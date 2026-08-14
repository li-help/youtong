package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Course;
import com.youtong.service.CourseService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/course")
public class CourseController extends CrudController<Course, Long> {
    private final CourseService courseService;

    public CourseController(CourseService service) {
        super(service, "status", new String[]{"title", "teacher"});
        this.courseService = service;
    }

    /** C 端课程列表（支持关键词与分类筛选，公开） */
    @GetMapping
    public R list(@RequestParam(defaultValue = "1") Integer page,
                  @RequestParam(defaultValue = "20") Integer pageSize,
                  @RequestParam(required = false) String keyword,
                  @RequestParam(required = false) Long categoryId) {
        Page<Course> p = new Page<>(page, pageSize);
        QueryWrapper<Course> qw = new QueryWrapper<>();
        qw.eq("status", 1);
        if (keyword != null && !keyword.trim().isEmpty()) {
            qw.and(w -> w.like("title", keyword).or().like("teacher", keyword));
        }
        if (categoryId != null) {
            qw.eq("category_id", categoryId);
        }
        qw.orderByDesc("id");
        p = courseService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }

    /** C 端为你推荐课程（公开，取上架前若干条） */
    @GetMapping("/recommend")
    public R recommend(@RequestParam(defaultValue = "6") Integer size) {
        Page<Course> page = new Page<>(1, size);
        QueryWrapper<Course> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("id");
        page = courseService.page(page, qw);
        return R.ok(page.getRecords());
    }
}
