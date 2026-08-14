# 优童 (YouTong) —— 儿童教育类 App (uni-app + Vue3)

基于设计图实现的儿童教育类 App，包含登录注册、首页、智能推荐、课程、活动、视频、我的等完整模块。
后端接口对接 `http://localhost:3001/api`。

## 技术栈
- uni-app (Vue 3 + Vite)
- uni-ui 组件库
- 自封装 `uni.request` 请求层（自动携带 `Authorization: Bearer <token>`）

## 目录结构
```
uniapp/
├── index.html
├── main.js / App.vue
├── manifest.json / pages.json / uni.scss / vite.config.js
├── src/
│   ├── config.js          # BaseURL、占位图
│   ├── api/               # 接口封装（对齐后端 Controller）
│   │   ├── request.js     # 统一请求 + token 拦截
│   │   └── index.js       # auth/user/video/course/activity/store/order...
│   ├── store/             # 全局登录态 (user.js)
│   └── utils/
├── pages/
│   ├── login/ register/           # 登录 / 注册
│   ├── tabbar/ home/ ai/ course/ activity/ mine/   # 5 个 Tab
│   ├── course/ detail signup      # 课程详情 / 报名
│   ├── activity/ detail           # 活动详情
│   ├── video/ play                # 视频播放
│   ├── store/ detail              # 店铺详情
│   ├── article/ detail            # 学习天地
│   ├── order/ list                # 我的订单
│   ├── ai/ result                 # 智能推荐结果
│   └── mine/ profile qrcode help  # 修改信息 / 二维码 / 使用说明
└── static/tab/                    # Tab 图标占位（可替换为设计图素材）
```

## 运行方式
```bash
# 1. 安装依赖
npm install

# 2. 运行 H5（浏览器预览，推荐）
npm run dev:h5
# 启动后访问 http://localhost:8080

# 3. 运行微信小程序（需 HBuilderX 或 CLI）
npm run dev:mp-weixin

# 4. 运行 App（需 HBuilderX 真机/模拟器）
npm run dev:app
```

## 说明
- 主题色：主色 `#FFA000` / 亮黄 `#FFC107` / 背景 `#FFF8E1`
- 所有图标（Tab、课程封面等）均使用 emoji 或纯色占位图，未引入设计图原始图片素材
- 后端未启动时，登录页与多个列表页内置兜底逻辑，可进入演示模式预览 UI
- 真实图片素材可后续替换 `static/tab/` 下图标及接口返回的 cover 字段
