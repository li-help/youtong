-- ============================================================
-- 优童成长社 - 数据库结构补齐脚本
-- 用途：将当前数据库表结构与 Java 实体对齐，避免 500
-- 说明：
--   - 对已存在的列使用 @col_exists 判断，重复执行安全
--   - 仅新增缺失的表/字段，不删除已有数据
-- ============================================================

DELIMITER $$

-- ---------- favorite 收藏表 ----------
CREATE TABLE IF NOT EXISTS `favorite` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id`     BIGINT        NOT NULL COMMENT '用户ID（sys_account.id）',
  `target_type` VARCHAR(64)   NOT NULL COMMENT '收藏类型：course/activity/video/article/store/service',
  `target_id`   BIGINT        NOT NULL COMMENT '收藏对象ID',
  `title`       VARCHAR(255)  DEFAULT '' COMMENT '收藏对象标题（冗余）',
  `cover`       VARCHAR(255)  DEFAULT '' COMMENT '收藏对象封面（冗余）',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_target` (`user_id`, `target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏'$$

-- ---------- user_address 用户地址表 ----------
CREATE TABLE IF NOT EXISTS `user_address` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id`     BIGINT        NOT NULL COMMENT '所属用户ID（sys_account.id）',
  `name`        VARCHAR(64)   DEFAULT '' COMMENT '收货人姓名',
  `phone`       VARCHAR(20)   DEFAULT '' COMMENT '联系电话',
  `region`      VARCHAR(255)  DEFAULT '' COMMENT '省市区',
  `detail`      VARCHAR(255)  DEFAULT '' COMMENT '详细地址',
  `is_default`  TINYINT       DEFAULT 0 COMMENT '是否默认地址：1是 0否',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收货地址'$$

-- ---------- store 补充字段 ----------
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
                   WHERE table_schema = DATABASE() AND table_name = 'store' AND column_name = 'phone')$$
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `store` ADD COLUMN `phone` VARCHAR(20) DEFAULT "" COMMENT "门店电话" AFTER `address`', 'SELECT "store.phone 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
                   WHERE table_schema = DATABASE() AND table_name = 'store' AND column_name = 'business_hours')$$
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `store` ADD COLUMN `business_hours` VARCHAR(64) DEFAULT "09:00 - 21:00" COMMENT "营业时间" AFTER `intro`', 'SELECT "store.business_hours 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

-- ---------- customer_service 补充字段 ----------
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
                   WHERE table_schema = DATABASE() AND table_name = 'customer_service' AND column_name = 'account_id')$$
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `customer_service` ADD COLUMN `account_id` BIGINT DEFAULT NULL COMMENT "关联sys_account的ID" AFTER `id`', 'SELECT "customer_service.account_id 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
                   WHERE table_schema = DATABASE() AND table_name = 'customer_service' AND column_name = 'store_id')$$
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `customer_service` ADD COLUMN `store_id` BIGINT DEFAULT 0 COMMENT "所属店铺ID(0为平台通用客服)" AFTER `account_id`', 'SELECT "customer_service.store_id 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
                   WHERE table_schema = DATABASE() AND table_name = 'customer_service' AND index_name = 'idx_store_id')$$
SET @sql = IF(@idx_exists = 0, 'ALTER TABLE `customer_service` ADD INDEX `idx_store_id` (`store_id`)', 'SELECT "idx_store_id 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
                   WHERE table_schema = DATABASE() AND table_name = 'customer_service' AND index_name = 'idx_account_id')$$
SET @sql = IF(@idx_exists = 0, 'ALTER TABLE `customer_service` ADD INDEX `idx_account_id` (`account_id`)', 'SELECT "idx_account_id 已存在"')$$
PREPARE stmt FROM @sql$$
EXECUTE stmt$$
DEALLOCATE PREPARE stmt$$

DELIMITER ;
