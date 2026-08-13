package com.youtong.controller;

import com.youtong.common.CrudController;
import com.youtong.entity.Article;
import com.youtong.service.ArticleService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/article")
public class ArticleController extends CrudController<Article, Long> {
    public ArticleController(ArticleService service) {
        super(service, "status", new String[]{"title", "author"});
    }
}
