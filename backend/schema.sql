-- ============================================================
-- 优童成长社 后台管理系统 数据库设计
-- 依据 后台设计图/ 下 12 张页面推导
-- 引擎: MySQL 8.0 (兼容 MariaDB)
-- 字符集: utf8mb4
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. 系统管理 - 系统账号 (系统管理.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_account`;
CREATE TABLE `sys_account` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '账号ID',
  `username`    VARCHAR(64)  NOT NULL COMMENT '登录账号',
  `password`    VARCHAR(128) NOT NULL COMMENT '密码(加密存储)',
  `nickname`    VARCHAR(64)  DEFAULT '' COMMENT '昵称',
  `role`        VARCHAR(32)  DEFAULT 'operator' COMMENT '角色: admin/operator',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `remark`      VARCHAR(255) DEFAULT '' COMMENT '备注',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统账号';

-- ------------------------------------------------------------
-- 2. 用户管理 - 用户 (用户.png)
--    字段: ID / 名称 / 编码 / 状态 / 备注 / 更新时间
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `name`        VARCHAR(64)  NOT NULL COMMENT '用户名称',
  `code`        VARCHAR(64)  NOT NULL COMMENT '用户编码',
  `phone`       VARCHAR(20)  DEFAULT '' COMMENT '手机号',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1正常 0禁用',
  `remark`      VARCHAR(255) DEFAULT '' COMMENT '备注',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户';

-- ------------------------------------------------------------
-- 3. 订单管理 - 课程订单 (订单.png)
--    字段: 订单号 / 金额 / 下单时间 / 状态 / 详情 / 核销
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no`    VARCHAR(64)  NOT NULL COMMENT '订单号',
  `user_id`     BIGINT       DEFAULT NULL COMMENT '下单用户ID',
  `course_id`   BIGINT       DEFAULT NULL COMMENT '课程ID',
  `course_name` VARCHAR(255) DEFAULT NULL COMMENT '课程名称',
  `amount`      DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单金额',
  `status`      TINYINT      NOT NULL DEFAULT 0 COMMENT '状态: 0待支付 1已支付 2已核销 3已取消',
  `contact_name` VARCHAR(50) DEFAULT NULL COMMENT '报名人姓名',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '报名人电话',
  `age_range`   VARCHAR(20)  DEFAULT NULL COMMENT '宝宝年龄段',
  `remark`      VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `paid_at`     DATETIME     DEFAULT NULL COMMENT '支付时间',
  `verify_at`   DATETIME     DEFAULT NULL COMMENT '核销时间',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程订单';

-- ------------------------------------------------------------
-- 4. 店铺管理 - 店铺 (店铺.png)
--    字段: 门店名称 / 地址 / Logo / 评分 / 简介 / 坐标 / 操作
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `store`;
CREATE TABLE `store` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '店铺ID',
  `name`        VARCHAR(128) NOT NULL COMMENT '门店名称',
  `address`     VARCHAR(255) DEFAULT '' COMMENT '地址',
  `logo`        VARCHAR(255) DEFAULT '' COMMENT 'Logo URL',
  `score`       DECIMAL(2,1) DEFAULT 5.0 COMMENT '评分(0-5)',
  `intro`       VARCHAR(512) DEFAULT '' COMMENT '简介',
  `lng`         DECIMAL(10,6) DEFAULT NULL COMMENT '经度',
  `lat`         DECIMAL(10,6) DEFAULT NULL COMMENT '纬度',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1营业 0歇业',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺';

-- ------------------------------------------------------------
-- 5. 分类管理 - 分类 (分类.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name`        VARCHAR(64)  NOT NULL COMMENT '分类名称',
  `parent_id`   BIGINT       DEFAULT 0 COMMENT '父分类ID(0为一级)',
  `sort`        INT          DEFAULT 0 COMMENT '排序',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类';

-- ------------------------------------------------------------
-- 6. 广告管理 - 广告位 + 广告 (广告位.png / 添加广告.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `ad_position`;
CREATE TABLE `ad_position` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '广告位ID',
  `name`        VARCHAR(64)  NOT NULL COMMENT '广告位名称',
  `code`        VARCHAR(64)  NOT NULL COMMENT '广告位编码',
  `size`        VARCHAR(32)  DEFAULT '' COMMENT '尺寸(如 750x300)',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告位';

DROP TABLE IF EXISTS `ad`;
CREATE TABLE `ad` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '广告ID',
  `position_id` BIGINT       NOT NULL COMMENT '广告位ID',
  `title`       VARCHAR(128) NOT NULL COMMENT '广告标题',
  `image`       VARCHAR(255) DEFAULT '' COMMENT '广告图片URL',
  `url`         VARCHAR(255) DEFAULT '' COMMENT '跳转链接',
  `start_time`  DATETIME     DEFAULT NULL COMMENT '开始时间',
  `end_time`    DATETIME     DEFAULT NULL COMMENT '结束时间',
  `sort`        INT          DEFAULT 0 COMMENT '排序',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_position` (`position_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告';

-- ------------------------------------------------------------
-- 7. 视频管理 - 视频 (视频.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `video`;
CREATE TABLE `video` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `title`       VARCHAR(128) NOT NULL COMMENT '标题',
  `cover`       VARCHAR(255) DEFAULT '' COMMENT '封面URL',
  `url`         VARCHAR(255) DEFAULT '' COMMENT '视频地址',
  `duration`    INT          DEFAULT 0 COMMENT '时长(秒)',
  `category_id` BIGINT       DEFAULT NULL COMMENT '分类ID',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1上线 0下线',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='视频';

-- ------------------------------------------------------------
-- 8. 课程管理 - 课程 (课程.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '课程ID',
  `title`       VARCHAR(128) NOT NULL COMMENT '课程标题',
  `cover`       VARCHAR(255) DEFAULT '' COMMENT '封面URL',
  `price`       DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格',
  `category_id` BIGINT       DEFAULT NULL COMMENT '分类ID',
  `teacher`     VARCHAR(64)  DEFAULT '' COMMENT '讲师',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1在售 0下架',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程';

-- ------------------------------------------------------------
-- 9. 活动管理 - 活动 (活动.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `activity`;
CREATE TABLE `activity` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  `title`       VARCHAR(128) NOT NULL COMMENT '活动标题',
  `cover`       VARCHAR(255) DEFAULT '' COMMENT '封面URL',
  `start_time`  DATETIME     DEFAULT NULL COMMENT '开始时间',
  `end_time`    DATETIME     DEFAULT NULL COMMENT '结束时间',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1进行中 0已结束',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动';

-- ------------------------------------------------------------
-- 10. 文章管理 - 文章 (文章.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `title`       VARCHAR(128) NOT NULL COMMENT '标题',
  `cover`       VARCHAR(255) DEFAULT '' COMMENT '封面URL',
  `content`     LONGTEXT     COMMENT '正文',
  `author`      VARCHAR(64)  DEFAULT '' COMMENT '作者',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1已发布 0草稿',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章';

-- ------------------------------------------------------------
-- 11. 客服管理 - 客服 (客服.png)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `customer_service`;
CREATE TABLE `customer_service` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '客服ID',
  `name`        VARCHAR(64)  NOT NULL COMMENT '客服名称',
  `avatar`      VARCHAR(255) DEFAULT '' COMMENT '头像URL',
  `phone`       VARCHAR(20)  DEFAULT '' COMMENT '联系电话',
  `online`      TINYINT      NOT NULL DEFAULT 1 COMMENT '在线状态: 1在线 0离线',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客服';

SET FOREIGN_KEY_CHECKS = 1;
