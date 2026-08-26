package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 业务 FAQ 知识库实体
 */
@Data
@TableName("faq_knowledge")
public class FaqKnowledge {
    private Long id;
    private String category;
    private String question;
    private String keywords;
    private String answer;
    private Integer sort;
    private Integer status;
    private Long hitCount;
    private String createdAt;
    private String updatedAt;
}
