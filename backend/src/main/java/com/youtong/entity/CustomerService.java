package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("customer_service")
public class CustomerService {
    private Long id;
    private String name;
    private String avatar;
    private String phone;
    private Integer online;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
