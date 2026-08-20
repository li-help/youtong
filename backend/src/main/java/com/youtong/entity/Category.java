package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("category")
public class Category {
    private Long id;
    private String name;
    private Long parentId;
    private Integer sort;
    private Integer status;
    private String createdAt;
    private String updatedAt;

    /** 父分类名称（非表字段，列表展示用） */
    @TableField(exist = false)
    private String parentName;
}
