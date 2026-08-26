package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * IM 聊天会话实体
 */
@Data
@TableName("im_session")
public class ImSession {
    private Long id;
    private String sessionNo;
    private Long userId;
    private Long storeId;
    private Long csId;
    /** 1-AI客服会话, 2-人工客服会话 */
    private Integer sessionType;
    private String lastMsgContent;
    private String lastMsgTime;
    private Integer unreadCountUser;
    private Integer unreadCountCs;
    /** 1-进行中, 2-已结束 */
    private Integer status;
    private String createdAt;
    private String updatedAt;

    /** 扩展属性：用户昵称/客服昵称/店铺名称 */
    @TableField(exist = false)
    private String userName;
    @TableField(exist = false)
    private String userAvatar;
    @TableField(exist = false)
    private String csName;
    @TableField(exist = false)
    private String csAvatar;
    @TableField(exist = false)
    private String storeName;
}
