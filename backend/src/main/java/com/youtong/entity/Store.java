package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;

@Data
@TableName("store")
public class Store {
    private Long id;
    private String name;
    private String address;
    private String logo;
    private BigDecimal score;
    private String intro;
    private BigDecimal lng;
    private BigDecimal lat;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
