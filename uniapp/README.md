# 优童成长 uniapp 客户端

基于 **标准 uni-app 框架（Vue3）** 的 C 端客户端，可直接用 **HBuilderX** 打开运行，无需 `npm install` / `npm run dev`。

## 项目结构

```
uniapp/
├─ src/
│  ├─ main.js            # 标准 uni-app Vue3 入口（createApp）
│  ├─ App.vue            # 应用根组件
│  ├─ pages.json         # 页面路由与 tabBar 配置
│  ├─ manifest.json      # 应用配置（含 H5 代理）
│  ├─ config.js          # 常量、图片兜底、接口地址
│  ├─ api/
│  │  ├─ request.js      # 统一请求封装（token、错误提示、R 结构解析）
│  │  └─ index.js        # 各业务模块 API（对接后端 youtong-admin-backend）
│  ├─ store/
│  │  └─ user.js         # 全局用户态（reactive 单例）
│  ├─ pages/             # 各业务页面
│  └─ static/            # 静态资源
```

## 运行方式（HBuilderX）

1. 用 **HBuilderX** 打开本目录（菜单：文件 → 打开目录，选择 `uniapp` 文件夹）。
2. 顶部菜单「运行」：
   - 运行到浏览器（H5）：`运行 → 运行到浏览器 → Chrome`
   - 运行到手机/模拟器：先连接设备，再 `运行 → 运行到手机或模拟器`
   - 微信小程序：`运行 → 运行到小程序模拟器 → 微信开发者工具`（需先配置 AppId）
3. 无需任何依赖安装步骤，HBuilderX 会自动编译。

## 后端联调

前端默认通过相对路径 `/api` 访问后端，H5 下由 `manifest.json` 的
`h5.devServer.proxy` 转发到 `http://localhost:3001`：

```json
"h5": {
  "devServer": {
    "proxy": { "/api": { "target": "http://localhost:3001", "changeOrigin": true } }
  }
}
```

> 真机 / 小程序调试时，请把 `src/api/request.js` 中的 `BASE_URL` 改为
> 电脑的局域网 IP，例如 `http://192.168.1.100:3001/api`，并确保后端已启动。

## 后端接口约定

后端工程位于 `../backend`（Spring Boot，端口 3001），关键 C 端接口：

| 功能       | 接口                              | 鉴权 |
|------------|-----------------------------------|------|
| 登录       | POST /api/auth/login              | 否   |
| 注册       | POST /api/auth/register           | 否   |
| 课程列表   | GET  /api/course/list             | 否   |
| 课程推荐   | GET  /api/course/recommend        | 否   |
| 课程详情   | GET  /api/course/{id}             | 否*  |
| 门店列表   | GET  /api/store/list              | 否   |
| 门店详情   | GET  /api/store/{id}              | 否*  |
| 服务列表   | GET  /api/service/list            | 否   |
| 活动列表   | GET  /api/activity                | 否   |
| 视频列表   | GET  /api/video                   | 否   |
| 资讯列表   | GET  /api/article/published       | 否   |
| 轮播       | GET  /api/banner/{code}           | 否   |
| 个人信息   | GET  /api/user/me                 | 是   |
| 订单列表   | GET  /api/order                   | 是   |

\* 详情接口仅放行 GET 方法，写操作（修改/删除）仍需登录，由后端 `JwtInterceptor` 控制。

## 注意事项

- 本项目为标准 uni-app 工程，**不要**使用 `npm` / `vite` 命令运行（相关 CLI 配置已移除）。
- 修改后端接口后，若前端 `api/index.js` 路径不同步，需同步更新。
