package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Category;
import com.youtong.service.CategoryService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/category")
public class CategoryController extends CrudController<Category, Long> {
    public CategoryController(CategoryService service) {
        super(service, "status", new String[]{"name"});
    }
}
