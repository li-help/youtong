#!/usr/bin/env bash
# ============================================================
# 优童成长社 - 数据库初始化脚本（幂等，可重复执行）
#
# 用法:
#   bash init-db.sh [schema.sql] [seed.sql]
#
# 环境变量:
#   MYSQL_ROOT_PASSWORD   MySQL root 密码（优先级最高）
#   MYSQL_PASSWORD        应用账号 youtong 的密码（默认方式）
#   FORCE=1               强制重建表（会清空现有数据，仅限首次初始化使用！）
#
# 说明:
#   首次执行（库中无表）时导入 schema.sql + seed.sql；
#   重复执行时检测到已有表则跳过，避免覆盖线上数据。
# ============================================================
set -e

SCHEMA=${1:-schema.sql}
SEED=${2:-seed.sql}
DB=youtong

if [ ! -f "$SCHEMA" ]; then
  echo "错误: 找不到表结构文件 $SCHEMA（可用: bash init-db.sh /opt/youtong/app/schema.sql /opt/youtong/app/seed.sql）"
  exit 1
fi
if [ ! -f "$SEED" ]; then
  echo "错误: 找不到种子数据文件 $SEED"
  exit 1
fi

# ---------- 选择 MySQL 连接方式 ----------
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
  MYSQL_CMD="mysql -uroot -p${MYSQL_ROOT_PASSWORD}"
elif [ -n "$MYSQL_PASSWORD" ]; then
  MYSQL_CMD="mysql -uyoutong -p${MYSQL_PASSWORD} -h127.0.0.1"
else
  MYSQL_CMD="mysql -uroot"
fi

echo "==> 确保数据库 $DB 存在 (utf8mb4)"
$MYSQL_CMD -e "CREATE DATABASE IF NOT EXISTS $DB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

TABLE_COUNT=$($MYSQL_CMD -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB'" 2>/dev/null || echo 0)

if [ "$FORCE" = "1" ]; then
  echo "==> FORCE=1 强制重建表结构（$DB 库现有数据将被清空）"
  $MYSQL_CMD "$DB" < "$SCHEMA"
  $MYSQL_CMD "$DB" < "$SEED"
elif [ "$TABLE_COUNT" -gt 0 ]; then
  echo "==> 检测到 $DB 库已有 $TABLE_COUNT 张表，尝试增量创建新表..."
  # 利用 CREATE TABLE IF NOT EXISTS 跳过已存在表，自动创建新增表（如 faq_knowledge/im_session/im_message）
  $MYSQL_CMD "$DB" < "$SCHEMA"
  echo "   如需强制重建: FORCE=1 bash init-db.sh <schema.sql> <seed.sql>"
else
  echo "==> 首次初始化：导入表结构 schema.sql 与种子数据 seed.sql"
  $MYSQL_CMD "$DB" < "$SCHEMA"
  $MYSQL_CMD "$DB" < "$SEED"
fi

echo "==> 完成。$DB 库当前表数量: $($MYSQL_CMD -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB'")"
