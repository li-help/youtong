package com.youtong.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("user_address")
public class UserAddress {
    private Long id;
    /** 所属用户ID（sys_account.id） */
    private Long userId;
    /** 收货人姓名 */
    private String name;
    /** 联系电话 */
    private String phone;
    /** 省市区 */
    private String region;
    /** 详细地址 */
    private String detail;
    /** 是否默认地址：1是 0否 */
    private Integer isDefault;
    private String createdAt;
    private String updatedAt;
}
