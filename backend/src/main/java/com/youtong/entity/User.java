package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("user")
public class User {
    private Long id;
    private String name;
    private String code;
    private String phone;
    private Integer status;
    private String remark;
    private String createdAt;
    private String updatedAt;
}
