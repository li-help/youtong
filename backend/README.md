# 优童成长社后台 - Java 后端

基于 **Spring Boot 3 + MyBatis-Plus + MySQL** 的后端服务，实现 11 个业务模块的增删改查（CRUD），
接口路径、参数与前端 `admin/src/api/mock.js` 中预留的接口完全一致，可直接对接前端。

## 技术栈
- Spring Boot 3.2
- MyBatis-Plus 3.5（通用 Mapper / 分页插件）
- MySQL 8（mysql-connector-j）
- Java 17

## 目录结构
```
backend/
├── pom.xml                       # Maven 依赖
├── schema.sql                    # 数据库建表语句（11 个模块表）
├── README.md
└── src/main/java/com/youtong/
    ├── YoutongAdminApplication    # 启动类
    ├── common/                    # R(统一返回) / PageQuery / CrudController(通用CRUD基类)
    ├── config/                    # CorsConfig(跨域) / MybatisPlusConfig(分页)
    ├── entity/                    # 11 个实体类（对应表）
    ├── mapper/                    # 11 个 Mapper（继承 BaseMapper）
    └── controller/                # 11 个 Controller（10 通用 + 订单特殊）
```

## 快速开始
1. 准备 MySQL，创建数据库并导入表结构：
   ```sql
   CREATE DATABASE youtong_admin CHARACTER SET utf8mb4;
   USE youtong_admin;
   SOURCE backend/schema.sql;
   ```
2. 修改 `src/main/resources/application.yml` 中的数据库连接（url / username / password）。
3. 构建并运行：
   ```bash
   mvn clean package
   java -jar target/youtong-admin-backend-1.0.0.jar
   # 或开发模式
   mvn spring-boot:run
   ```
   默认监听 `http://localhost:3001`。

## 接口一览
| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/sys/account` | 账号列表（分页/关键词/状态） |
| GET/POST/PUT/DELETE | `/api/user` | 用户 CRUD |
| GET/POST/PUT/DELETE | `/api/store` | 店铺 CRUD |
| GET/POST/PUT/DELETE | `/api/category` | 分类 CRUD |
| GET/POST/PUT/DELETE | `/api/ad/position` | 广告位 CRUD |
| GET/POST/PUT/DELETE | `/api/ad` | 广告 CRUD |
| GET/POST/PUT/DELETE | `/api/video` | 视频 CRUD |
| GET/POST/PUT/DELETE | `/api/course` | 课程 CRUD |
| GET/POST/PUT/DELETE | `/api/activity` | 活动 CRUD |
| GET/POST/PUT/DELETE | `/api/article` | 文章 CRUD |
| GET/POST/PUT/DELETE | `/api/service` | 客服 CRUD |
| GET | `/api/order` | 订单列表（含 statusText） |
| POST | `/api/order/{id}/verify` | 订单核销 |

所有列表接口支持查询参数：`page`、`pageSize`、`keyword`、`status`。
统一返回体：`{ code: 0, data: {...}, message: "ok" }`（code≠0 表示失败）。

## 前端对接（联调）
前端已默认切换为真实后端模式（`admin/src/api/request.js` 中 `USE_MOCK = false`），
开发时通过 Vite 代理把 `/api` 转发到后端 `http://localhost:3001`，无需额外配置。

### 联调运行顺序
1. 启动 MySQL，创建库并导入表结构：
   ```sql
   CREATE DATABASE youtong CHARACTER SET utf8mb4;
   USE youtong;
   SOURCE backend/schema.sql;
   ```
   > 注意 `application.yml` 中默认库名是 `youtong`、账号/密码 `root/root`，请按本机实际修改。
2. 启动后端（端口 3001）：
   ```bash
   cd backend
   mvn spring-boot:run
   ```
3. 启动前端（端口 5173，自动代理 /api 到后端）：
   ```bash
   cd admin
   npm install
   npm run dev
   ```
4. 浏览器打开 `http://localhost:5173`，所有列表/新增/编辑/删除/核销均走真实接口。

### 如需直连后端（不走代理）
在 `admin/.env` 中设置 `VITE_API_BASE_URL=http://localhost:3001/api`，
并将 `request.js` 的 `USE_MOCK` 保持为 `false` 即可（后端已开启 CORS）。
