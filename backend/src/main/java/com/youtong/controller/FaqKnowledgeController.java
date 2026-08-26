package com.youtong.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.youtong.common.CrudController;
import com.youtong.common.R;
import com.youtong.entity.FaqKnowledge;
import com.youtong.service.DataVersionService;
import com.youtong.service.FaqKnowledgeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/faq")
public class FaqKnowledgeController extends CrudController<FaqKnowledge, Long> {

    private final FaqKnowledgeService faqKnowledgeService;

    public FaqKnowledgeController(FaqKnowledgeService service, DataVersionService dataVersionService) {
        super(service, "status", new String[]{"question", "keywords", "category"}, "faq", dataVersionService);
        this.faqKnowledgeService = service;
    }

    /** C 端公开 FAQ 列表 */
    @GetMapping("/list")
    public R listForC() {
        List<FaqKnowledge> list = faqKnowledgeService.list(new QueryWrapper<FaqKnowledge>()
                .eq("status", 1)
                .orderByDesc("sort")
                .orderByDesc("id"));
        return R.ok(list);
    }

    /** C 端公开热门 FAQ 列表 */
    @GetMapping("/hot")
    public R hotList(@RequestParam(defaultValue = "6") Integer limit) {
        List<FaqKnowledge> list = faqKnowledgeService.list(new QueryWrapper<FaqKnowledge>()
                .eq("status", 1)
                .orderByDesc("sort")
                .orderByDesc("hit_count")
                .last("LIMIT " + limit));
        return R.ok(list);
    }
}
