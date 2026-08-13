package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("ad")
public class Ad {
    private Long id;
    private Long positionId;
    private String title;
    private String image;
    private String url;
    private String startTime;
    private String endTime;
    private Integer sort;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
