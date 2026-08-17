#!/usr/bin/env bash
# ============================================================
# 优童成长社 - 服务器收尾脚本（在 server-init.sh 之后执行）
# 说明: 启动 MySQL、导入表结构与种子数据
# ============================================================
set -e

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
MYSQL_CMD="mysql -uroot"
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
  MYSQL_CMD="mysql -uroot -p${MYSQL_ROOT_PASSWORD}"
fi

echo "==> [1/3] 启动 MySQL 并设置开机自启"
systemctl enable --now mysql 2>/dev/null || service mysql start
sleep 3
systemctl is-active mysql

echo "==> [2/3] 导入表结构 schema.sql"
$MYSQL_CMD youtong < /tmp/schema.sql

echo "==> [3/3] 导入种子数据 seed.sql"
$MYSQL_CMD youtong < /tmp/seed.sql

echo ""
echo "=============================================="
echo " 数据库初始化完成！"
echo " 表数量: $($MYSQL_CMD -N -e 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=\"youtong\"')"
echo " 默认管理员: admin / 123456"
echo "=============================================="
