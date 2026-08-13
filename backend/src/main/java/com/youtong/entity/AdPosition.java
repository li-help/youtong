package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("ad_position")
public class AdPosition {
    private Long id;
    private String name;
    private String code;
    private String size;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
