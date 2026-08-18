# 优童成长社（youtong）

面向 0-6 岁儿童家庭的母婴服务与成长陪伴平台，包含管理后台、C 端小程序/H5/App、AI 智能推荐三大块。

## 项目结构

```
├── admin/      # 管理后台前端（Vue3 + Vite + Element Plus）
├── app/        # C 端 App（Flutter）
├── uniapp/     # C 端 H5 / 小程序（uni-app + Vue3）
├── backend/    # 后端服务（Spring Boot 3 + MyBatis-Plus + MySQL）
└── deploy/     # 部署脚本与上线文档
```

## 技术栈

| 端 | 技术 |
|---|---|
| 管理后台 | Vue 3 + Vite + Element Plus + Pinia |
| C 端 App | Flutter |
| C 端 H5/小程序 | uni-app (Vue 3) |
| 后端 | Spring Boot 3 + MyBatis-Plus + JWT |
| 数据库 | MySQL 8.0 |
| 部署 | GitHub Actions CI/CD + Nginx + systemd |

## 本地开发

### 后端

```bash
cd backend
# 修改 src/main/resources/application.yml 中的数据库连接
mvn spring-boot:run
# 启动前初始化数据库
mysql -uroot -p youtong < schema.sql
mysql -uroot -p youtong < seed.sql
```

### 管理后台

```bash
cd admin
npm install --registry=https://registry.npmmirror.com
npm run dev        # http://localhost:5173（/api 代理到 3001）
```

### C 端 uniapp

```bash
cd uniapp
npm install
npm run dev:h5     # 用 HBuilderX 打开 uniapp 目录也可直接运行
```

### C 端 Flutter App

```bash
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3001/api
```

## 部署上线

完整的上线流程（服务器初始化、GitHub Secrets 配置、数据库初始化、HTTPS、C 端打包、回滚）请参见：

👉 **[deploy/README-DEPLOY.md](deploy/README-DEPLOY.md)**

简要流程：

1. 服务器执行 `bash deploy/server-init.sh`（安装 JDK/Nginx/MySQL、建库、配 systemd 与 Nginx）
2. 仓库配置 GitHub Secrets：`SERVER_HOST` / `SERVER_USER` / `SSH_PRIVATE_KEY` / `APP_UPLOAD_DIR` / `MYSQL_PASSWORD`
3. 推送 `main` 分支自动触发 GitHub Actions 部署（含幂等数据库初始化与健康检查）
4. 正式环境配置 HTTPS（certbot），C 端通过 `UNI_APP_API_URL` / `--dart-define=API_BASE_URL` 注入生产地址

## 默认账号

- 后台管理员：`admin / 123456`（上线后请立即修改）
- 演示验证码：后端返回明文 `code`（生产环境接入真实短信平台）

## 说明

- 数据库脚本：`backend/schema.sql`（表结构）、`backend/seed.sql`（种子数据）
- 接口鉴权：JWT，白名单见 `backend/src/main/java/com/youtong/common/JwtInterceptor.java`
- 实时同步：C 端轮询 `GET /api/sync/version?channel=xxx`（后台修改内容后版本号自增）
