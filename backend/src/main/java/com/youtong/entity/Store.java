package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;

@Data
@TableName("store")
public class Store {
    private Long id;
    private String name;
    private String address;
    private String phone;
    private String logo;
    private BigDecimal score;
    private String intro;
    private String businessHours;
    private BigDecimal lng;
    private BigDecimal lat;
    private Integer status;
    private String createdAt;
    private String updatedAt;

    /** 非库字段：到当前用户定位的距离（千米），供接口计算并返回 */
    @TableField(exist = false)
    private Double distance;
}
