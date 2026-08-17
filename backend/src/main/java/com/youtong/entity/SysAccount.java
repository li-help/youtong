package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("sys_account")
public class SysAccount {
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String phone;
    private String avatar;
    private String babyAge;
    private String remark;
    private String openid;
    private String role;
    private Integer status;
    private String createdAt;
    private String updatedAt;
}
