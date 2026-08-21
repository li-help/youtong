-- 用户中心功能增量表：收货地址 + 收藏
-- 幂等：已存在表不会重复创建，直接执行即可

-- 收货地址
CREATE TABLE IF NOT EXISTS `user_address` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '所属用户ID（sys_account.id）',
  `name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
  `region` VARCHAR(100) DEFAULT '' COMMENT '省市区',
  `detail` VARCHAR(255) NOT NULL COMMENT '详细地址',
  `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认地址 1是 0否',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址';

-- 用户收藏
CREATE TABLE IF NOT EXISTS `favorite` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（sys_account.id）',
  `target_type` VARCHAR(20) NOT NULL COMMENT '收藏类型：course/activity/video/article/store/service',
  `target_id` BIGINT NOT NULL COMMENT '收藏对象ID',
  `title` VARCHAR(255) DEFAULT '' COMMENT '收藏对象标题（冗余）',
  `cover` VARCHAR(500) DEFAULT '' COMMENT '收藏对象封面（冗余）',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target` (`user_id`, `target_type`, `target_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏';
