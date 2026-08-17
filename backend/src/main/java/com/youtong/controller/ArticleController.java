package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.Article;
import com.youtong.service.ArticleService;
import com.youtong.service.DataVersionService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/article")
public class ArticleController extends CrudController<Article, Long> {
    private final ArticleService articleService;

    public ArticleController(ArticleService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"title", "author"}, "article", dataVersionService);
        this.articleService = service;
    }

    /** C 端已发布资讯列表（公开） */
    @GetMapping("/published")
    public R published(@RequestParam(defaultValue = "1") Integer page,
                       @RequestParam(defaultValue = "10") Integer pageSize) {
        Page<Article> p = new Page<>(page, pageSize);
        QueryWrapper<Article> qw = new QueryWrapper<>();
        qw.eq("status", 1).orderByDesc("created_at", "id");
        p = articleService.page(p, qw);
        return R.ok(R.page(p.getTotal(), p.getRecords(), p.getCurrent(), p.getSize()));
    }

    /** C 端资讯详情（公开） */
    @GetMapping("/view/{id}")
    public R view(@PathVariable Long id) {
        return R.ok(articleService.getById(id));
    }
}
