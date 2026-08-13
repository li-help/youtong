-- ============================================================
-- 优童成长社 后台管理系统 示例数据
-- 用于本地联调，可重复执行（先清空再插入）
-- ============================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 清空（TRUNCATE 会重置自增，方便重复执行）
TRUNCATE TABLE `sys_account`;
TRUNCATE TABLE `user`;
TRUNCATE TABLE `order`;
TRUNCATE TABLE `store`;
TRUNCATE TABLE `category`;
TRUNCATE TABLE `ad_position`;
TRUNCATE TABLE `ad`;
TRUNCATE TABLE `video`;
TRUNCATE TABLE `course`;
TRUNCATE TABLE `activity`;
TRUNCATE TABLE `article`;
TRUNCATE TABLE `customer_service`;

-- 1. 系统账号（密码均为 123456 的 BCrypt 密文）
INSERT INTO `sys_account` (`username`,`password`,`nickname`,`role`,`status`,`remark`) VALUES
('admin','$2a$10$wjlCL48LGr/oIN/ch1wYO.kfaDrP.yPa883cj.GGzvTXaQDmNH6oK','超级管理员','admin',1,'默认管理员'),
('operator01','$2a$10$wjlCL48LGr/oIN/ch1wYO.kfaDrP.yPa883cj.GGzvTXaQDmNH6oK','运营小李','operator',1,'内容运营'),
('operator02','$2a$10$wjlCL48LGr/oIN/ch1wYO.kfaDrP.yPa883cj.GGzvTXaQDmNH6oK','运营小王','operator',0,'已停用');

-- 2. 用户
INSERT INTO `user` (`name`,`code`,`phone`,`status`,`remark`) VALUES
('张小明','U10001','13800001001',1,'VIP会员'),
('李华','U10002','13800001002',1,'普通会员'),
('王芳','U10003','13800001003',1,'VIP会员'),
('赵强','U10004','13800001004',0,'已禁用'),
('陈静','U10005','13800001005',1,'普通会员');

-- 3. 分类（含二级）
INSERT INTO `category` (`name`,`parent_id`,`sort`,`status`) VALUES
('兴趣培养',0,1,1),
('学科辅导',0,2,1),
('绘画',1,1,1),
('音乐',1,2,1),
('数学',2,1,1),
('英语',2,2,0);

-- 4. 店铺
INSERT INTO `store` (`name`,`address`,`logo`,`score`,`intro`,`lng`,`lat`,`status`) VALUES
('优童中心旗舰店','北京市朝阳区建国路88号','https://picsum.photos/seed/s1/200',4.8,'专注3-12岁儿童成长综合服务',116.461,39.909,1),
('优童海淀分店','北京市海淀区中关村大街1号','https://picsum.photos/seed/s2/200',4.6,'学科辅导与兴趣培养',116.316,39.983,1),
('优童朝阳分店','北京市朝阳区望京SOHO','https://picsum.photos/seed/s3/200',4.5,'艺术与音乐培训',116.470,39.996,0);

-- 5. 广告位
INSERT INTO `ad_position` (`name`,`code`,`size`,`status`) VALUES
('首页轮播','home_banner','750x300',1),
('活动弹窗','activity_popup','600x800',1),
('侧边栏','side_bar','300x200',0);

-- 6. 广告
INSERT INTO `ad` (`position_id`,`title`,`image`,`url`,`start_time`,`end_time`,`sort`,`status`) VALUES
(1,'暑期成长计划','https://picsum.photos/seed/a1/750/300','/activity/1','2026-07-01 00:00:00','2026-08-31 23:59:59',1,1),
(1,'新生体验课','https://picsum.photos/seed/a2/750/300','/course/2','2026-08-01 00:00:00','2026-09-30 23:59:59',2,1),
(2,'开学季抽奖','https://picsum.photos/seed/a3/600/800','/activity/3','2026-08-15 00:00:00','2026-09-15 23:59:59',1,0);

-- 7. 课程（依赖 category）
INSERT INTO `course` (`title`,`cover`,`price`,`category_id`,`teacher`,`status`) VALUES
('少儿创意绘画入门','https://picsum.photos/seed/c1/400',299.00,3,'周老师',1),
('钢琴基础班','https://picsum.photos/seed/c2/400',599.00,4,'林老师',1),
('小学数学思维','https://picsum.photos/seed/c3/400',399.00,5,'吴老师',1),
('少儿英语口语','https://picsum.photos/seed/c4/400',459.00,6,'Tom',0),
('亲子手工课','https://picsum.photos/seed/c5/400',199.00,3,'陈老师',1);

-- 8. 视频（依赖 category）
INSERT INTO `video` (`title`,`cover`,`url`,`duration`,`category_id`,`status`) VALUES
('如何培养孩子专注力','https://picsum.photos/seed/v1/400','https://example.com/v/1.mp4',320,1,1),
('5分钟学会简笔画','https://picsum.photos/seed/v2/400','https://example.com/v/2.mp4',180,3,1),
('亲子阅读指南','https://picsum.photos/seed/v3/400','https://example.com/v/3.mp4',540,1,0);

-- 9. 活动
INSERT INTO `activity` (`title`,`cover`,`start_time`,`end_time`,`status`) VALUES
('2026暑期成长营','https://picsum.photos/seed/ac1/400','2026-07-10 09:00:00','2026-08-20 18:00:00',1),
('开学季亲子市集','https://picsum.photos/seed/ac2/400','2026-09-01 10:00:00','2026-09-03 17:00:00',1),
('已结束的试运营','https://picsum.photos/seed/ac3/400','2026-05-01 10:00:00','2026-05-31 18:00:00',0);

-- 10. 文章
INSERT INTO `article` (`title`,`cover`,`content`,`author`,`status`) VALUES
('儿童情绪管理家长必读','https://picsum.photos/seed/ar1/400','<p>本文介绍如何帮助孩子识别和管理情绪...</p>','编辑部',1),
('暑期学习计划制定指南','https://picsum.photos/seed/ar2/400','<p>一份可落地的暑期学习计划模板...</p>','王老师',1),
('草稿：新学期开学准备','https://picsum.photos/seed/ar3/400','<p>待补充内容</p>','编辑部',0);

-- 11. 客服
INSERT INTO `customer_service` (`name`,`avatar`,`phone`,`online`,`status`) VALUES
('客服小优','https://picsum.photos/seed/cs1/100','400-800-1234',1,1),
('客服小童','https://picsum.photos/seed/cs2/100','400-800-5678',1,1),
('客服小星','https://picsum.photos/seed/cs3/100','400-800-9012',0,0);

-- 12. 订单（依赖 user / course，覆盖多种状态以测试核销与筛选）
INSERT INTO `order` (`order_no`,`user_id`,`course_id`,`amount`,`status`,`paid_at`,`verify_at`) VALUES
('YT20260801001',1,1,299.00,1,'2026-08-01 10:12:00',NULL),
('YT20260802002',2,2,599.00,2,'2026-08-02 09:30:00','2026-08-03 14:20:00'),
('YT20260803003',3,3,399.00,0,NULL,NULL),
('YT20260804004',1,5,199.00,1,'2026-08-04 16:45:00',NULL),
('YT20260805005',4,4,459.00,3,'2026-08-05 11:00:00',NULL),
('YT20260806006',5,1,299.00,1,'2026-08-06 19:20:00',NULL);

SET FOREIGN_KEY_CHECKS = 1;
