package com.youtong.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youtong.entity.FaqKnowledge;
import com.youtong.mapper.FaqKnowledgeMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FaqKnowledgeService extends ServiceImpl<FaqKnowledgeMapper, FaqKnowledge> {

    /**
     * 根据用户提问进行 FAQ 知识库检索匹配
     */
    public FaqKnowledge matchFaq(String query) {
        if (query == null || query.isBlank()) return null;
        String cleanQuery = query.trim();

        // 1. 精确/包含匹配问题
        List<FaqKnowledge> list = list(new QueryWrapper<FaqKnowledge>()
                .eq("status", 1)
                .orderByDesc("sort"));
        
        for (FaqKnowledge faq : list) {
            // 匹配问题文本
            if (cleanQuery.contains(faq.getQuestion()) || faq.getQuestion().contains(cleanQuery)) {
                baseMapper.incrementHitCount(faq.getId());
                return faq;
            }
            // 匹配关键词 (逗号/空格分隔)
            if (faq.getKeywords() != null && !faq.getKeywords().isBlank()) {
                String[] kws = faq.getKeywords().split("[,，\\s]+");
                for (String kw : kws) {
                    if (!kw.isBlank() && cleanQuery.contains(kw.trim())) {
                        baseMapper.incrementHitCount(faq.getId());
                        return faq;
                    }
                }
            }
        }
        return null;
    }
}
