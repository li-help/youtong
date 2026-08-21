-- 修复线上数据库中仍指向 picsum.photos 的图片外链
-- 国内访问 picsum.photos 不稳定，统一改为本地 /uploads/placeholder.jpg
-- 执行前请确保后端已启动（会自动生成 placeholder.jpg）或已手动放置该文件

UPDATE `store` SET `logo` = '/uploads/placeholder.jpg' WHERE `logo` LIKE 'https://picsum.photos/%';
UPDATE `ad` SET `image` = '/uploads/placeholder.jpg' WHERE `image` LIKE 'https://picsum.photos/%';
UPDATE `course` SET `cover` = '/uploads/placeholder.jpg' WHERE `cover` LIKE 'https://picsum.photos/%';
UPDATE `video` SET `cover` = '/uploads/placeholder.jpg' WHERE `cover` LIKE 'https://picsum.photos/%';
UPDATE `activity` SET `cover` = '/uploads/placeholder.jpg' WHERE `cover` LIKE 'https://picsum.photos/%';
UPDATE `article` SET `cover` = '/uploads/placeholder.jpg' WHERE `cover` LIKE 'https://picsum.photos/%';
UPDATE `customer_service` SET `avatar` = '/uploads/placeholder.jpg' WHERE `avatar` LIKE 'https://picsum.photos/%';
