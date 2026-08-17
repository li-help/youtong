#!/usr/bin/env bash
# ============================================================
# 优童成长社 - 服务器初始化脚本（一次性执行）
# 用法: bash server-init.sh
# 说明: 在服务器 123.56.160.50 首次部署前执行本脚本
# ============================================================
set -e

# ---------- 0. 检查 root ----------
if [ "$EUID" -ne 0 ]; then
  echo "请用 root 执行: sudo bash server-init.sh"
  exit 1
fi

APP_DIR=/opt/youtong
UPLOAD_DIR=${APP_UPLOAD_DIR:-$APP_DIR/uploads}
DB_PASS=${MYSQL_PASSWORD:-""}
IP=${SERVER_HOST:-$(curl -s ifconfig.me)}

echo "==> [1/6] 安装依赖 (JDK17 + Nginx + Rsync)"
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y openjdk-17-jre-headless nginx rsync curl unzip
elif command -v yum >/dev/null 2>&1; then
  yum install -y java-17-openjdk-headless nginx rsync curl unzip || true
else
  echo "不支持的系统，请手动安装 JDK17/Nginx/Rsync"
  exit 1
fi

echo "==> [2/6] 创建应用目录"
mkdir -p $APP_DIR/app $APP_DIR/admin $UPLOAD_DIR
chmod -R 755 $APP_DIR

echo "==> [3/6] 安装 MySQL"
if ! command -v mysql >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get install -y mysql-server || yum install -y mysql-server
fi
systemctl enable --now mysql || systemctl enable --now mysqld || true

echo "==> [4/6] 初始化数据库"
if [ -z "$DB_PASS" ]; then
  read -sp "请输入新数据库密码: " DB_PASS
  echo ""
fi
# 创建数据库与账号（先尝试执行，若已存在则忽略报错）
mysql -uroot <<SQL || true
CREATE DATABASE IF NOT EXISTS youtong DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'youtong'@'localhost' IDENTIFIED BY '${DB_PASS}';
CREATE USER IF NOT EXISTS 'youtong'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON youtong.* TO 'youtong'@'localhost';
GRANT ALL PRIVILEGES ON youtong.* TO 'youtong'@'%';
FLUSH PRIVILEGES;
SQL
echo "数据库初始化完成（库: youtong / 用户: youtong）"

echo "==> [5/6] 安装 systemd 服务"
cat > /etc/systemd/system/youtong.service <<SVC
[Unit]
Description=Youtong Backend
After=network.target mysql.service

[Service]
WorkingDirectory=$APP_DIR/app
ExecStart=/usr/bin/java -jar $APP_DIR/app/app.jar
Restart=always
RestartSec=5
Environment=APP_UPLOAD_DIR=$UPLOAD_DIR
Environment=SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/youtong?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
Environment=SPRING_DATASOURCE_USERNAME=youtong
Environment=SPRING_DATASOURCE_PASSWORD=${DB_PASS}

[Install]
WantedBy=multi-user.target
SVC
systemctl daemon-reload
systemctl enable youtong

echo "==> [6/6] 配置 Nginx 反向代理"
cat > /etc/nginx/conf.d/youtong.conf <<NGX
server {
    listen 80;
    server_name $IP;

    # 后台前端
    root $APP_DIR/admin;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # 后端 API
    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # 上传资源
    location /uploads/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host \$host;
    }

    # SSE 实时同步（必须关缓冲）
    location /api/stream/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 3600s;
    }
}
NGX
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo ""
echo "=============================================="
echo " 服务器初始化完成！"
echo " 后台地址: http://$IP"
echo " 后端端口: 3001 (经 /api 反代)"
echo " 上传目录: $UPLOAD_DIR"
echo " 下一步: 在 GitLab Runner 上执行首次部署"
echo "=============================================="
