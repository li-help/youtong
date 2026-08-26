package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * IM 聊天消息记录实体
 */
@Data
@TableName("im_message")
public class ImMessage {
    private Long id;
    private Long sessionId;
    private String clientMsgId;
    /** 1-用户, 2-客服, 3-AI机器人, 4-系统通知 */
    private Integer senderType;
    private Long senderId;
    private Long receiverId;
    /** text, image, faq, transfer_notice */
    private String msgType;
    private String content;
    /** 0-未读, 1-已读 */
    private Integer isRead;
    /** 1-成功, 2-发送中, 3-失败 */
    private Integer status;
    private String createdAt;

    /** 发送方昵称与头像 */
    @TableField(exist = false)
    private String senderName;
    @TableField(exist = false)
    private String senderAvatar;
}
