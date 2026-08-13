package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("activity")
public class Activity {
    private Long id;
    private String title;
    private String cover;
    private String startTime;
    private String endTime;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
