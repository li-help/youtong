package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;

@Data
@TableName("`order`")
public class Order {
    private Long id;
    private String orderNo;
    private Long userId;
    private Long courseId;
    private BigDecimal amount;
    private Integer status;
    private String paidAt;
    private String verifyAt;
    private String createdAt;
    private String updatedAt;
    @TableField(exist = false)
    private String statusText;
}
