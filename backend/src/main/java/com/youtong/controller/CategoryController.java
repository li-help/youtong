package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Category;
import com.youtong.service.CategoryService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/category")
public class CategoryController extends CrudController<Category, Long> {
    private final CategoryService categoryService;

    public CategoryController(CategoryService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"name"}, "category", dataVersionService);
        this.categoryService = service;
    }

    /** C 端分类列表（公开，仅启用 status=1） */
    @GetMapping("/list")
    public R cList(@RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "20") Integer pageSize) {
        Page<Category> p = new Page<>(page, pageSize);
        QueryWrapper<Category> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByAsc("sort").orderByAsc("id");
        p = categoryService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }
}
