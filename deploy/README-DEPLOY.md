# 优童成长社 · 部署上线指南

本仓库提供完整的 CI/CD 部署方案：代码推送到 `main` 分支后，GitHub Actions 自动构建后端 jar 与后台前端 dist，并部署到生产服务器。

---

## 1. 架构总览

```
客户端                             服务器 (Ubuntu/CentOS)
─────────────────────────────────────────────────────────────
Flutter App / uniapp (H5/小程序) ─┐
                                  │   HTTPS / HTTP
后台管理 (admin，Nginx 托管) ──────┤────→ Nginx :80 (:443)
                                  │        │  /api/      → 后端 :3001
                                  │        │  /uploads/  → 后端 :3001
                                  │        └  /api/stream/→ 后端 :3001 (SSE)
GitHub Actions (CI/CD) ───────────┘
                                  └→ systemd youtong.service
                                       └─ Spring Boot app.jar
                                            └─ MySQL 8.0 (youtong 库)
```

部署目录结构：

| 路径 | 说明 |
|---|---|
| `/opt/youtong/app/app.jar` | 后端可执行 jar（CI 覆盖） |
| `/opt/youtong/admin/` | 后台前端静态文件（CI 覆盖） |
| `/opt/youtong/app/schema.sql` / `seed.sql` | 数据库脚本（CI 上传） |
| `/opt/youtong/app/migrate_schema_to_match_entities.sql` | 幂等增量列迁移脚本（CI 上传，给已有表补新增列） |
| `/opt/youtong/init-db.sh` | 幂等数据库初始化脚本（CI 上传） |
| `/opt/youtong/backup/app-*.jar` | 历史 jar 备份（自动保留 10 份） |
| `${APP_UPLOAD_DIR}` | 上传的图片等资源（默认 `/opt/youtong/uploads`） |

---

## 2. 首次部署（GitHub Actions 方式）

### 2.1 前置准备

1. 一台云服务器（2C4G 起），可访问外网，操作系统 Ubuntu 20.04+ 或 CentOS 7+。
2. 一个已解析到服务器 IP 的域名（**正式环境建议配置，微信小程序强制要求 HTTPS**）。
3. 本仓库已推送到 GitHub。

### 2.2 第 1 步：服务器初始化（一次性）

```bash
# 上传部署脚本到服务器
scp -r deploy root@<服务器IP>:/opt/deploy

# 在服务器上执行（推荐 root）
cd /opt/deploy
MYSQL_PASSWORD='<数据库密码>' \
WECHAT_SECRET='<微信小程序AppSecret>' \
DEEPSEEK_API_KEY='<DeepSeek密钥>' \
SERVER_HOST='<服务器IP>' \
bash server-init.sh
```

脚本会自动完成：

- 安装 JDK17 / Nginx / Rsync / MySQL
- 创建目录 `/opt/youtong/{app,admin,backup}` 与上传目录
- 创建数据库 `youtong` 与账号 `youtong`
- 安装 systemd 服务 `youtong.service`（注入数据库密码、微信、DeepSeek 环境变量）
- 生成 Nginx 反向代理配置（`/api`、`/uploads`、SSE）

> 若跳过敏感变量，服务会使用 `application.yml` 中的默认值（演示可用），正式环境务必显式传入。

### 2.3 第 2 步：配置 GitHub Secrets

在仓库 **Settings → Secrets and variables → Actions → New repository secret** 中配置：

| Secret | 说明 | 示例 |
|---|---|---|
| `SERVER_HOST` | 服务器 IP | `123.56.160.50` |
| `SERVER_USER` | SSH 登录用户 | `root` |
| `SSH_PRIVATE_KEY` | 服务器 SSH 私钥（含 `-----BEGIN...`） | — |
| `APP_UPLOAD_DIR` | 上传目录 | `/opt/youtong/uploads` |
| `MYSQL_PASSWORD` | 数据库账号 `youtong` 的密码（与 2.2 一致） | — |

> `SSH_PRIVATE_KEY` 需与服务器 `authorized_keys` 中配置的公钥配对。`MYSQL_PASSWORD` 用于 CI 在首次部署时自动导入表结构与种子数据（幂等，已有表则跳过）。

### 2.4 第 3 步：触发首次部署

- 推送代码到 `main` 分支会自动触发；也可在 Actions 页面手动 **Run workflow**。

CI 部署流程：

1. 构建后端 jar、后台 dist
2. 备份服务器旧 jar（保留最近 10 份）
3. 上传 jar、后台 dist、SQL 脚本、`init-db.sh`
4. **幂等初始化数据库**（首次导入 `schema.sql` + `seed.sql`；之后仅补建缺失的新表，并执行 `migrate_schema_to_match_entities.sql` 给已有表补新增列）
5. `systemctl restart youtong`
6. **健康检查**：轮询 `GET /api/sync/version?channel=health`，60 秒内返回 200 视为成功，否则失败并提示日志查看命令

### 2.5 第 4 步：验证

```bash
# 服务状态
systemctl status youtong
journalctl -u youtong -n 50 --no-pager

# 接口连通（服务器本机）
curl http://127.0.0.1:3001/api/sync/version?channel=health
curl http://127.0.0.1:3001/api/video/list?status=1

# 浏览器访问后台
http://<服务器IP>        # 默认管理员 admin / 123456（上线后请立即修改）
```

---

## 3. 数据库初始化（独立使用）

`deploy/init-db.sh` 为幂等脚本，可在任意机器上使用：

```bash
# 在服务器上（脚本已由 CI 上传到 /opt/youtong/init-db.sh）
cd /opt/youtong
MYSQL_PASSWORD='<密码>' bash init-db.sh app/schema.sql app/seed.sql

# 强制重建（清空现有数据，仅限首次初始化！）
FORCE=1 MYSQL_PASSWORD='<密码>' bash init-db.sh app/schema.sql app/seed.sql
```

- 库中无表时：自动导入表结构与种子数据。
- 库中已有表时：跳过导入，**不会覆盖线上数据**。

---

## 4. HTTPS 配置（正式环境必需）

微信小程序、支付等场景强制要求 HTTPS。推荐使用 certbot：

```bash
# 安装并签发证书（域名已解析到本机）
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

签发后 Nginx 配置会自动加入 443 监听。随后：

- 后台访问：`https://your-domain.com`
- API 地址：`https://your-domain.com/api`
- 修改 `deploy/server-init.sh` 中的 `server_name` 为域名后重新执行 Nginx 配置，或直接编辑 `/etc/nginx/conf.d/youtong.conf`。

---

## 5. C 端（uniapp / Flutter App）打包配置

### uniapp（H5 / 小程序 / App）

修改 `uniapp/config.js` 中的 `BASE_URL`，或构建时注入环境变量：

```bash
# H5 构建（静态文件可托管到任意静态服务器，或并入 Nginx）
UNI_APP_API_URL=https://your-domain.com/api npm run build:h5

# App 打包（HBuilderX 云打包时在 config.js 中直接写生产地址）
```

> 小程序需在 `manifest.json` 配置已认证的 `appid`，并在微信公众平台配置服务器域名白名单（`request` 合法域名 = `https://your-domain.com`）。

### Flutter App

构建时通过 `--dart-define` 注入生产地址（无需改代码）：

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api --release
```

---

## 6. 回滚

CI 每次部署会自动备份旧 jar 至 `/opt/youtong/backup/`（保留 10 份）。需要回滚时：

```bash
# 查看可用备份
ls -1t /opt/youtong/backup/

# 回滚到指定版本（例如 10 分钟前部署的包）
cd /opt/youtong/app
cp /opt/youtong/backup/app-20260818-103000.jar app.jar
systemctl restart youtong

# 验证
curl http://127.0.0.1:3001/api/sync/version?channel=health
```

后台前端如需回滚：从对应提交重新构建 dist 上传，或先备份 `/opt/youtong/admin/` 再覆盖。

---

## 7. 常见问题

| 现象 | 排查 |
|---|---|
| CI 部署失败：健康检查不通过 | `journalctl -u youtong -n 100`；确认数据库账号密码与 `MYSQL_PASSWORD` 一致；首次部署需先执行 `server-init.sh` |
| 后台 502 / API 超时 | `systemctl status youtong`、`curl 127.0.0.1:3001`；检查 MySQL 是否存活 `systemctl status mysql` |
| 图片上传后打不开 | 确认 `APP_UPLOAD_DIR` 目录存在且服务账号可写；Nginx `/uploads/` 反代已配置 |
| 小程序请求被拒 | 微信公众平台配置 request 合法域名；确认已启用 HTTPS |
| 修改了 `.gitlab-ci.yml` 但 GitHub 不生效 | GitHub 使用 `.github/workflows/deploy.yml`，两套流水线相互独立 |
