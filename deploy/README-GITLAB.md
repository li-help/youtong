# ============================================================
# 优童成长社 GitLab CI/CD 部署说明
# 目标服务器: 123.56.160.50
# 流水线文件: .gitlab-ci.yml
# ============================================================

## 一、整体流程

```
本地 push 到 GitLab main 分支
        │
        ▼
GitLab Runner 执行流水线
  ① build-backend  → maven 打包 jar
  ② build-admin    → npm 打包后台 dist
  ③ deploy(手动)   → rsync 上传 + 重启服务
        │
        ▼
服务器 123.56.160.50
  /opt/youtong/app/app.jar   后端 Spring Boot (端口 3001)
  /opt/youtong/admin/        后台 Nginx 静态
  /opt/youtong/uploads/      上传图片
```

## 二、首次部署步骤（一次性）

### 1. 准备 GitLab 仓库
- 在 GitLab 创建空项目 `youtong`（私库）
- 本地添加远程并推送：
  ```bash
  git remote add gitlab git@gitlab.com:<你的账号>/youtong.git
  git push -u gitlab main
  ```

### 2. 在服务器上执行初始化（只需一次）
将 `deploy/server-init.sh` 传到服务器并运行：
```bash
scp deploy/server-init.sh root@123.56.160.50:/tmp/
ssh root@123.56.160.50 "bash /tmp/server-init.sh"
```
脚本会自动安装 JDK17/Nginx/MySQL、建库、写 systemd 服务、配 Nginx。
> 脚本末尾会要求输入数据库密码，请记住该密码。

### 3. 安装并注册 GitLab Runner
服务器上安装 GitLab Runner（用服务器本机跑，构建产物直接落服务器）：
```bash
# Ubuntu/Debian
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt-get install -y gitlab-runner

# 注册（token 在 GitLab → 项目 → Settings → CI/CD → Runners 里找）
gitlab-runner register \
  --url https://gitlab.com/ \
  --token <你的项目runner-token> \
  --executor shell \
  --description "youtong-prod"

# shell 执行器需要构建工具
apt-get install -y maven nodejs npm
```
> 注册后回到流水线，Runner 会显示为在线。

### 4. 配置 GitLab CI/CD 变量
GitLab 项目 → **Settings → CI/CD → Variables** 新增：

| 变量名 | 值 | 说明 |
|---|---|---|
| `SERVER_HOST` | `123.56.160.50` | 服务器 IP |
| `SERVER_USER` | `root` | SSH 用户 |
| `SSH_PRIVATE_KEY` | （服务器 `~/.ssh/id_rsa` 私钥全文） | 部署免密 |
| `APP_UPLOAD_DIR` | `/opt/youtong/uploads` | 上传目录 |
| `MYSQL_PASSWORD` | 第 2 步设的密码 | 服务环境变量（可选） |
| `WECHAT_SECRET` | 微信小程序 secret | 建议生产注入（不注入则用代码内默认值） |
| `DEEPSEEK_API_KEY` | DeepSeek API Key | 建议生产注入（不注入则用代码内默认值） |

所有变量勾选 **Masked**（SSH_PRIVATE_KEY 需 Protected+Masked）。

### 5. 推送触发流水线
```bash
git push gitlab main
```
流水线前两步自动跑，第三步 **deploy** 默认是手动触发（`.gitlab-ci.yml` 中 `when: manual`），
在 GitLab 流水线页面点 **▶ 播放** 按钮执行部署。

## 三、日常更新上线
```bash
git add -A && git commit -m "..." && git push gitlab main
# 然后到 GitLab 流水线点手动 deploy（若希望自动部署，把 when: manual 改为 on_success）
```

## 四、回滚
服务器上保留旧 jar：
```bash
# 若新包异常，用备份的旧包回滚（首次部署时建议先备份）
ssh root@123.56.160.50
cp /opt/youtong/app/app.jar /opt/youtong/app/app.jar.bak
systemctl restart youtong
```
> 也可以把 jar 按版本命名（如 app-1.0.0.jar），在 CI 中保留上一版本路径。

## 五、常见问题
- **部署步骤找不到 service**：服务器初始化脚本未跑或服务名不同，先执行初始化脚本。
- **rsync 权限不足**：确认 `SERVER_USER` 对 `/opt/youtong` 有写权限。
- **HTTPS 未配置**：正式环境建议用 certbot 申请证书，并把 Flutter/uniapp 地址改为 https。
- **数据库连不上**：检查 `SPRING_DATASOURCE_PASSWORD` 是否与第 2 步一致。
