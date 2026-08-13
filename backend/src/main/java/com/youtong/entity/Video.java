package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("video")
public class Video {
    private Long id;
    private String title;
    private String cover;
    private String url;
    private Integer duration;
    private Long categoryId;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
