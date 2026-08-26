-- ============================================================
-- 优童成长社 增量数据库升级脚本
-- 用于在现有已运行的数据库上执行，无需清空原有业务数据
-- ============================================================

-- 1. 店铺表增量字段
ALTER TABLE `store` 
  ADD COLUMN `phone` VARCHAR(20) DEFAULT '' COMMENT '门店电话' AFTER `address`,
  ADD COLUMN `business_hours` VARCHAR(64) DEFAULT '09:00 - 21:00' COMMENT '营业时间' AFTER `intro`;

-- 2. 客服表增量字段
ALTER TABLE `customer_service` 
  ADD COLUMN `account_id` BIGINT DEFAULT NULL COMMENT '关联sys_account的ID' AFTER `id`,
  ADD COLUMN `store_id` BIGINT DEFAULT 0 COMMENT '所属店铺ID(0为平台通用客服)' AFTER `account_id`;

-- 3. 新建 FAQ 知识库表
CREATE TABLE IF NOT EXISTS `faq_knowledge` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT 'FAQ ID',
  `category`    VARCHAR(64)   DEFAULT '通用' COMMENT '分类(如: 课程咨询/入园指导/退改规则)',
  `question`    VARCHAR(255)  NOT NULL COMMENT '标准问题',
  `keywords`    VARCHAR(255)  DEFAULT '' COMMENT '匹配关键词(逗号分隔)',
  `answer`      TEXT          NOT NULL COMMENT '标准回答内容',
  `sort`        INT           DEFAULT 0 COMMENT '排序权重',
  `status`      TINYINT       NOT NULL DEFAULT 1 COMMENT '状态: 1启用 0禁用',
  `hit_count`   BIGINT        DEFAULT 0 COMMENT '命中次数统计',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_keywords` (`keywords`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务FAQ知识库';

-- 4. 新建 IM 聊天会话表
CREATE TABLE IF NOT EXISTS `im_session` (
  `id`                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `session_no`         VARCHAR(64)  NOT NULL COMMENT '会话唯一标识(如 sess_uid_storeId)',
  `user_id`            BIGINT       NOT NULL COMMENT '用户ID(关联sys_account.id)',
  `store_id`           BIGINT       DEFAULT 0 COMMENT '店铺ID(0为平台客服)',
  `cs_id`              BIGINT       DEFAULT NULL COMMENT '接待客服ID(关联customer_service.id)',
  `session_type`       TINYINT      NOT NULL DEFAULT 1 COMMENT '会话类型: 1-AI客服会话, 2-人工客服会话',
  `last_msg_content`   VARCHAR(512) DEFAULT '' COMMENT '最新消息预览',
  `last_msg_time`      DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '最新消息时间',
  `unread_count_user`  INT          DEFAULT 0 COMMENT '用户侧未读数',
  `unread_count_cs`    INT          DEFAULT 0 COMMENT '客服侧未读数',
  `status`             TINYINT      DEFAULT 1 COMMENT '状态: 1-进行中, 2-已结束',
  `created_at`         DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`         DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_no` (`session_no`),
  KEY `idx_user_store` (`user_id`, `store_id`),
  KEY `idx_cs_id` (`cs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='IM聊天会话';

-- 5. 新建 IM 聊天消息记录表
CREATE TABLE IF NOT EXISTS `im_message` (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `session_id`     BIGINT        NOT NULL COMMENT '会话ID',
  `client_msg_id`  VARCHAR(64)   NOT NULL COMMENT '客户端生成防重ID(UUID/时间戳)',
  `sender_type`    TINYINT       NOT NULL COMMENT '发送方: 1-用户, 2-客服, 3-AI机器人, 4-系统通知',
  `sender_id`      BIGINT        NOT NULL COMMENT '发送方ID(用户ID/客服ID/0)',
  `receiver_id`    BIGINT        NOT NULL COMMENT '接收方ID',
  `msg_type`       VARCHAR(20)   DEFAULT 'text' COMMENT '消息类型: text/image/faq/transfer_notice',
  `content`        TEXT          NOT NULL COMMENT '消息文本或JSON数据',
  `is_read`        TINYINT       DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
  `status`         TINYINT       DEFAULT 1 COMMENT '发送状态: 1-成功, 2-发送中, 3-失败',
  `created_at`     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_client_msg` (`client_msg_id`),
  KEY `idx_session_time` (`session_id`, `created_at`),
  KEY `idx_receiver_read` (`receiver_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='IM聊天消息记录';

-- 6. 预置基础 FAQ 样例数据
INSERT INTO `faq_knowledge` (`category`, `question`, `keywords`, `answer`, `sort`, `status`) VALUES
('课程咨询', '如何报名儿童早教与体验课程？', '报名,课程,预约,体验课', '您可以在平台底部【课程】页面浏览感兴趣的课程，点击进入详情页后点击【立即报名】，填写宝宝信息并完成支付即可完成报名。', 10, 1),
('退改规则', '报名后因故无法参加可以退款吗？', '退款,取消,退课,退费', '在课程开课前24小时以上可在【我的订单】申请全额退款；开课前24小时内申请将收取10%手续费；已核销或已开课课程暂不支持退款。', 9, 1),
('门店服务', '门店的营业时间和入园要求是什么？', '营业时间,入园,时间,门店', '各门店通常营业时间为每日 09:00 - 21:00。入园请携带防滑袜，陪同家长不超过2位。您可以在【店铺详情】查看具体门店的地址、电话并一键导航。', 8, 1),
('人工客服', '如何联系人工客服或门店老师？', '人工,人工客服,电话,联系方式,转人工', '如需人工帮助，您可以点击页面顶部的【转人工客服】按钮，或直接在店铺详情中拨打门店联系电话。', 7, 1);
