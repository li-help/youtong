package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("article")
public class Article {
    private Long id;
    private String title;
    private String cover;
    private String content;
    private String author;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
