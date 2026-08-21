package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("favorite")
public class Favorite {
    private Long id;
    /** 用户ID（sys_account.id） */
    private Long userId;
    /** 收藏类型：course/activity/video/article/store/service */
    private String targetType;
    /** 收藏对象ID */
    private Long targetId;
    /** 收藏对象标题（冗余，便于列表展示） */
    private String title;
    /** 收藏对象封面（冗余） */
    private String cover;
    private String createdAt;
}
