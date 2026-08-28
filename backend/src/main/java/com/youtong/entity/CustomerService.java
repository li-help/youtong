package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("customer_service")
public class CustomerService {
    private Long id;
    private Long accountId;
    private Long storeId;
    private String name;
    private String avatar;
    private String phone;
    private Integer online;
    private Integer status;
    private String createdAt;
    private String updatedAt;

    /** 关联展示字段（非表字段）：所属门店名称 / 绑定工作台账号名 */
    @TableField(exist = false)
    private String storeName;
    @TableField(exist = false)
    private String accountName;
}
