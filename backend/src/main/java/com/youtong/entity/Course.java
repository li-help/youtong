package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;

@Data
@TableName("course")
public class Course {
    private Long id;
    private String title;
    private String cover;
    private BigDecimal price;
    private Long categoryId;
    private String teacher;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
