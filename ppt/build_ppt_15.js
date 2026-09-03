/* 优童成长社 · 全栈项目答辩 PPT 生成脚本
 * 15 页 · 深色科技风（#0B1220 底 + 品牌橙 #FF8F00 强调）· 微软雅黑
 * 运行: node build_ppt.js
 */
const pptxgen = require("pptxgenjs");

const W = 13.33, H = 7.5, M = 0.5;
const F = "Microsoft YaHei";
const C = {
  bg: "0B1220", card: "141C2E", card2: "1A2540", card3: "0F1930",
  stroke: "263349", strokeDash: "32456B",
  or: "FF8F00", orLt: "FFB84D", orDim: "B36D1A",
  blue: "3B82F6", blueLt: "60A5FA",
  green: "34D399", red: "F87171", amber: "FBBF24",
  txt: "E5E7EB", mut: "94A3B8", faint: "64748B",
};

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE";
pres.author = "优童成长社";
pres.title = "优童成长社 · 全栈项目答辩";
pres.theme = { headFontFace: F, bodyFontFace: F };

const shadow = () => ({ type: "outer", color: "000000", blur: 8, offset: 3, angle: 90, opacity: 0.3 });
const bu = (color) => ({ code: "25B8", indent: 12, color: color || C.or });

function newSlide() { const s = pres.addSlide(); s.background = { color: C.bg }; return s; }

function header(s, idx, kicker, title) {
  s.addText([
    { text: idx, options: { bold: true } },
    { text: "  ·  " + kicker },
  ], { x: M, y: 0.34, w: 9, h: 0.3, fontSize: 12, color: C.or, fontFace: F, margin: 0, charSpacing: 2 });
  s.addText(title, { x: M, y: 0.66, w: 11.9, h: 0.55, fontSize: 25, bold: true, color: C.txt, fontFace: F, margin: 0 });
  s.addText(idx + " / 15", { x: 12.05, y: 7.08, w: 0.78, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0, align: "right" });
}

function card(s, x, y, w, h, o = {}) {
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: 0.09,
    fill: { color: o.fill || C.card },
    line: { color: o.line || C.stroke, width: o.lw === undefined ? 1 : o.lw, dashType: o.dash || "solid" },
    shadow: o.noShadow ? undefined : shadow(),
  });
}

function chip(s, x, y, w, h, text, o = {}) {
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: 0.07,
    fill: { color: o.fill || C.card2 },
    line: { color: o.line || C.stroke, width: 0.75 },
  });
  s.addText(text, {
    x, y, w, h, align: "center", valign: "middle", fontSize: o.fs || 12,
    color: o.color || C.txt, fontFace: F, margin: 0, bold: !!o.bold,
  });
}

function dotRows(s, x, y, w, items, o = {}) {
  const gap = o.gap || 0.52, fs = o.fs || 12.5, dc = o.dot || C.or;
  items.forEach((it, i) => {
    const t = typeof it === "string" ? { t: it } : it;
    const yy = y + i * gap;
    s.addShape(pres.shapes.OVAL, { x, y: yy + 0.085, w: 0.09, h: 0.09, fill: { color: t.dot || dc } });
    s.addText(t.t, {
      x: x + 0.22, y: yy, w: w - 0.22, h: t.h || o.h || 0.42, fontSize: fs,
      color: t.color || o.color || C.txt, fontFace: F, margin: 0, valign: "top",
    });
  });
}

// 小标签 + 正文 行（用于 需求/方案/效果、问题/方案/效果）
function kv(s, x, y, w, label, text, lc, o = {}) {
  s.addText(label, { x, y: y + 0.02, w: 0.58, h: 0.3, fontSize: 12, bold: true, color: lc, fontFace: F, margin: 0 });
  s.addText(text, {
    x: x + 0.66, y, w: w - 0.66, h: o.h || 0.62, fontSize: o.fs || 12,
    color: o.color || C.txt, fontFace: F, margin: 0, valign: "top",
  });
}

function arrowR(s, x1, y, x2, color, wd) {
  s.addShape(pres.shapes.LINE, { x: x1, y, w: x2 - x1, h: 0, line: { color: color || C.faint, width: wd || 1.75, endArrowType: "triangle" } });
}
function arrowD(s, x, y1, y2, color, wd) {
  s.addShape(pres.shapes.LINE, { x, y: y1, w: 0, h: y2 - y1, line: { color: color || C.faint, width: wd || 1.75, endArrowType: "triangle" } });
}

/* ============================================================ S1 封面 */
(() => {
  const s = newSlide();
  s.addText("全 栈 项 目 答 辩", { x: 0, y: 1.42, w: W, h: 0.35, align: "center", fontSize: 14, color: C.or, fontFace: F, charSpacing: 6, bold: true, margin: 0 });
  s.addText("优童成长社", { x: 0, y: 1.86, w: W, h: 1.15, align: "center", fontSize: 58, bold: true, color: C.txt, fontFace: F, margin: 0 });
  s.addText("面向 0~6 岁儿童家庭的母婴服务与成长陪伴平台", { x: 0, y: 3.12, w: W, h: 0.4, align: "center", fontSize: 17, color: C.mut, fontFace: F, margin: 0 });

  s.addText([
    { text: "App · 小程序 · H5 · 管理后台 四端一体", options: { color: C.txt, bold: true } },
    { text: "    ｜    ", options: { color: C.faint } },
    { text: "AI 育儿助手 × 实时客服 IM × 全自动 CI/CD", options: { color: C.orLt, bold: true } },
  ], { x: 0, y: 3.82, w: W, h: 0.4, align: "center", fontSize: 15, fontFace: F, margin: 0 });

  const chips = ["Flutter App", "uni-app 小程序 / H5", "Vue3 管理后台", "Spring Boot 3 后端"];
  const cw = 2.42, cg = 0.24, total = chips.length * cw + (chips.length - 1) * cg;
  chips.forEach((t, i) => chip(s, (W - total) / 2 + i * (cw + cg), 4.62, cw, 0.52, t, { fs: 13, color: C.txt, fill: C.card2, bold: true }));

  s.addText("DeepSeek · 阿里云短信 · 微信开放能力 · GitHub Actions · Nginx · systemd · MySQL 8", {
    x: 0, y: 5.5, w: W, h: 0.32, align: "center", fontSize: 12, color: C.faint, fontFace: F, margin: 0,
  });
  s.addText("汇报人：＿＿＿＿（待补充）      2026 年 9 月", { x: 0, y: 6.35, w: W, h: 0.35, align: "center", fontSize: 13, color: C.mut, fontFace: F, margin: 0 });

  s.addNotes("各位好，今天汇报的项目是「优童成长社」——一个面向 0 到 6 岁儿童家庭的母婴服务平台。它有四个端：家长用的 App、微信小程序和 H5，运营用的管理后台，背后是一套 Spring Boot 服务。它目前已经真实部署在云服务器上运行，接下来我会从为什么做、怎么做、遇到了什么问题三个层面来汇报。");
})();

/* ============================================================ S2 背景与目标 */
(() => {
  const s = newSlide();
  header(s, "02", "项目背景", "家长的「信息焦虑」× 运营的「管理低效」");

  card(s, 0.5, 1.4, 6.05, 2.95);
  s.addText([{ text: "家长侧", options: { color: C.or, bold: true } }, { text: "   C 端用户", options: { color: C.mut } }],
    { x: 0.82, y: 1.62, w: 5.4, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  dotRows(s, 0.82, 2.14, 5.5, [
    "早教课程五花八门，越查越乱",
    "亲子活动不知道哪里有、怎么报名",
    "看中课程要电话咨询、线下跑腿",
    "育儿知识碎片化，不知道该信谁",
  ], { gap: 0.55, fs: 12.5 });

  card(s, 6.78, 1.4, 6.05, 2.95);
  s.addText([{ text: "运营侧", options: { color: C.blueLt, bold: true } }, { text: "   B 端管理员", options: { color: C.mut } }],
    { x: 7.1, y: 1.62, w: 5.4, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  dotRows(s, 7.1, 2.14, 5.5, [
    "课程 / 活动靠表格和微信群管理",
    "改一张宣传图都要等开发排期",
    "用户与订单数据散落，无法统计",
    "家长咨询全靠人工，效率极低",
  ], { gap: 0.55, fs: 12.5, dot: C.blue });

  s.addText("项目目标", { x: 0.5, y: 4.68, w: 3, h: 0.32, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  const steps = ["发现", "咨询", "下单", "参与"];
  steps.forEach((t, i) => {
    const bx = 0.5 + i * 1.82;
    chip(s, bx, 5.12, 1.42, 0.62, t, { fs: 15, bold: true, fill: C.card2, color: C.txt });
    if (i < 3) arrowR(s, bx + 1.46, 5.43, bx + 1.78, C.or, 2);
  });
  s.addText("家长端全流程线上闭环", { x: 0.5, y: 5.92, w: 7, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  card(s, 8.3, 4.68, 4.53, 1.98, { fill: C.card3 });
  s.addText([
    { text: "让家长在线完成全流程，", options: { breakLine: true } },
    { text: "让运营在后台完成全部管理 ——", options: { breakLine: true } },
    { text: "养娃不焦虑，管理不费力。", options: { color: C.orLt, bold: true } },
  ], { x: 8.62, y: 4.95, w: 3.95, h: 1.5, fontSize: 14, color: C.txt, fontFace: F, margin: 0, paraSpaceAfter: 6 });

  s.addNotes("先讲为什么做这个项目。家长这边，宝宝该上什么早教课、周末有什么亲子活动，信息又散又乱，看中了还要电话咨询、线下报名；运营这边，内容和订单靠表格和微信群管，改一张 banner 都要找程序员。这两边的矛盾是同一件事：服务数字化程度低。所以我们定的目标很明确——家长在一个平台里完成发现、咨询、下单、参与的全流程，运营在后台可视化地管所有内容，双方都不需要懂技术。");
})();

/* ============================================================ S3 需求分析 */
(() => {
  const s = newSlide();
  header(s, "03", "需求分析与功能概览", "两类角色 · 五大板块 · 12 个运营模块");

  card(s, 0.5, 1.35, 5.9, 3.5);
  s.addText([{ text: "家长端", options: { color: C.or, bold: true } }, { text: "   App / 小程序 / H5", options: { color: C.mut, fontSize: 12 } }],
    { x: 0.82, y: 1.56, w: 5.2, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  const feats = [
    ["首页", "Banner · 学习天地 · 精选视频 · 门店"],
    ["智能助手", "AI 问答 · 转人工 · 个性化推荐"],
    ["课程", "浏览 · 下单 · 订单 · 二维码核销"],
    ["活动", "详情 · 一键报名"],
    ["我的", "收藏 · 订单 · 地址 · 扫码登录"],
  ];
  feats.forEach((f, i) => {
    s.addText([
      { text: f[0] + "   ", options: { bold: true, color: C.orLt } },
      { text: f[1], options: { color: C.mut } },
    ], { x: 0.82, y: 2.06 + i * 0.55, w: 5.3, h: 0.4, fontSize: 12.5, fontFace: F, margin: 0 });
  });

  card(s, 6.63, 1.35, 6.2, 3.5);
  s.addText([{ text: "运营端", options: { color: C.blueLt, bold: true } }, { text: "   管理后台", options: { color: C.mut, fontSize: 12 } }],
    { x: 6.95, y: 1.56, w: 5.4, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  const mods = ["课程", "活动", "视频", "文章", "分类", "广告", "订单核销", "用户", "门店", "客服工作台", "FAQ 知识库", "系统账号"];
  mods.forEach((m, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    chip(s, 6.95 + col * 1.9, 2.06 + row * 0.66, 1.76, 0.52, m, { fs: 12, fill: C.card2 });
  });

  card(s, 0.5, 5.12, 12.33, 1.72, { fill: C.card3 });
  const stats = [["26", "uni-app 页面"], ["27", "Flutter 页面"], ["14", "后台视图"], ["108", "REST 接口"], ["17", "数据表"]];
  stats.forEach((st, i) => {
    const bx = 0.72 + i * 2.42;
    s.addText(st[0], { x: bx, y: 5.32, w: 2.3, h: 0.75, fontSize: 38, bold: true, color: C.or, fontFace: F, margin: 0, align: "center" });
    s.addText(st[1], { x: bx, y: 6.12, w: 2.3, h: 0.32, fontSize: 12, color: C.mut, fontFace: F, margin: 0, align: "center" });
  });

  s.addNotes("从用户视角看需求：家长需要找内容、问问题、报课程；运营需要管内容、管订单、管客服。对应到系统就是五大板块加十二个后台模块。请记住底部这组数字：三端加后台一共六十多个页面，后端一百零八个接口、十七张表。这个规模保证了后面讲的所有功能都是真实落地的，不是概念稿。特别提一句「智能」板块——它是 AI 问答加实时客服加个性化推荐的组合，这是整个项目的差异化所在。");
})();

/* ============================================================ S4 系统架构 */
(() => {
  const s = newSlide();
  header(s, "04", "系统整体架构", "一套后端服务四端 · REST / WebSocket / SSE 三条通道");

  // L1 客户端层
  card(s, 0.5, 1.22, 12.33, 1.0);
  s.addText("客户端层", { x: 0.78, y: 1.5, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  const clients = [
    ["Flutter App", "Android APK · Web"],
    ["uni-app", "微信小程序 · H5"],
    ["Vue3 管理后台", "Element Plus"],
    ["官网落地页", "产品介绍 · APK 下载"],
  ];
  clients.forEach((cl, i) => {
    const bx = 2.1 + i * 2.68;
    chip(s, bx, 1.4, 2.52, 0.64, "", { fill: C.card2 });
    s.addText([
      { text: cl[0], options: { bold: true, color: C.txt, breakLine: true } },
      { text: cl[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: bx, y: 1.4, w: 2.52, h: 0.64, align: "center", valign: "middle", fontSize: 12.5, fontFace: F, margin: 0 });
  });

  // 通道
  const chans = [
    ["REST  × 108 接口  ↓", C.blueLt],
    ["WebSocket  /ws/im 实时 IM  ↓", C.green],
    ["SSE  /api/sync/stream 内容同步  ↓", C.orLt],
  ];
  chans.forEach((cn, i) => {
    const cx = 2.1 + i * 3.61;
    chip(s, cx, 2.4, 3.3, 0.5, cn[0], { fs: 12, color: cn[1], fill: C.card3, line: C.strokeDash, bold: true });
  });

  // L2 接入层
  card(s, 0.5, 3.1, 12.33, 0.82);
  s.addText("接入层", { x: 0.78, y: 3.32, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText("Nginx：/api 反代 3001 ｜ /ws 协议升级 · 3600s ｜ SSE 关缓冲 ｜ 静态托管 uploads / H5 / Web / APK 下载", {
    x: 2.1, y: 3.1, w: 10.5, h: 0.82, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "middle",
  });

  // L3 应用层
  card(s, 0.5, 4.06, 12.33, 1.14);
  s.addText("应用层", { x: 0.78, y: 4.42, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText([
    { text: "Spring Boot 3.2.5（Java 17）：Controller ×20 → Service ×20 → Mapper ×17，CrudController 基类复用 12 个模块", options: { breakLine: true } },
    { text: "JWT 拦截器 + 30 条白名单 ｜ 统一响应 R{code,msg,data} ｜ 全局异常处理 ｜ WebSocket /ws/im 端点", options: { color: C.mut } },
  ], { x: 2.1, y: 4.18, w: 10.5, h: 0.92, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, paraSpaceAfter: 5, valign: "middle" });

  // L4 数据层
  card(s, 0.5, 5.34, 12.33, 0.82);
  s.addText("数据层", { x: 0.78, y: 5.56, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  const datas = [
    ["MySQL 8.0", "17 张表 · 索引 / 唯一键"],
    ["文件存储", "uploads · UUID 重命名"],
    ["运行环境", "阿里云 ECS + systemd 守护"],
  ];
  datas.forEach((d, i) => {
    const bx = 2.1 + i * 3.58;
    chip(s, bx, 5.44, 3.42, 0.62, "", { fill: C.card2 });
    s.addText([
      { text: d[0] + "  ", options: { bold: true, color: C.txt } },
      { text: d[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: bx, y: 5.44, w: 3.42, h: 0.62, align: "center", valign: "middle", fontSize: 12.5, fontFace: F, margin: 0 });
  });

  // L5 外部服务
  card(s, 0.5, 6.3, 12.33, 0.66, { dash: "dash", line: C.strokeDash, noShadow: true, fill: C.card3 });
  s.addText([
    { text: "外部服务   ", options: { bold: true, color: C.or } },
    { text: "DeepSeek 大模型（OpenAI 兼容协议）· 阿里云短信 · 微信开放能力（登录 / 小程序码）", options: { color: C.txt } },
    { text: "    密钥全部环境变量注入", options: { color: C.faint, fontSize: 11.5 } },
  ], { x: 2.1, y: 6.3, w: 10.5, h: 0.66, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("这是整体架构。最上面四个端共用同一套 REST API 和同一个数据库，功能开发一次、四端同时可用。中间 Nginx 是统一入口，托管的不只是 API，还有 WebSocket 长连接和 SSE 流。应用层是标准三层，二十个 Controller 对应二十个 Service。往下是 MySQL 十七张表加本地文件存储。三条通道分工明确：REST 管请求响应，WebSocket 管客服实时消息，SSE 管内容变更推送——后台改了内容，家长端自动刷新，不需要发版。如实说明：验证码、在线状态、版本号暂存 JVM 内存，Redis 在规划中。");
})();

/* ============================================================ S5 技术栈 */
(() => {
  const s = newSlide();
  header(s, "05", "技术栈选型", "每项技术都为解决具体问题");

  const techs = [
    ["Flutter", ["一套代码构建 Android APK + Web", "27 个页面，原生级体验"], "为什么：双端复用，边际成本低"],
    ["uni-app（Vue 3）", ["一套代码同时发布小程序 + H5", "覆盖家长最高频使用入口"], "为什么：小程序生态 + Web 一份代码"],
    ["Vue 3 + Element Plus + Vite", ["管理后台 14 个视图", "ListPage 通用组件：12 个列表页配置化"], "为什么：配置式开发，新页面几十行"],
    ["Spring Boot 3 + MyBatis-Plus", ["REST / WebSocket / SSE 同栈解决", "通用 CRUD 基类消除模板代码"], "为什么：一套技术栈扛全部通信"],
    ["MySQL 8.0", ["事务保障订单一致性", "唯一键支撑业务幂等 · 针对性索引"], "为什么：成熟稳定，生态完善"],
    ["DeepSeek · OpenAI 兼容协议", ["RestTemplate 直调，无 SDK 耦合", "60s 超时 + 异常降级兜底"], "为什么：配置化切换模型供应商"],
  ];
  techs.forEach((t, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    const x = 0.5 + col * 4.17, y = 1.35 + row * 2.3;
    card(s, x, y, 3.98, 2.12);
    s.addText(t[0], { x: x + 0.26, y: y + 0.18, w: 3.5, h: 0.34, fontSize: 14.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
    s.addText([
      { text: t[1][0], options: { breakLine: true } },
      { text: t[1][1] },
    ], { x: x + 0.26, y: y + 0.6, w: 3.5, h: 0.85, fontSize: 12, color: C.mut, fontFace: F, margin: 0, paraSpaceAfter: 5 });
    s.addText(t[2], { x: x + 0.26, y: y + 1.62, w: 3.5, h: 0.34, fontSize: 12, color: C.orLt, fontFace: F, margin: 0 });
  });

  card(s, 0.5, 6.06, 6.07, 0.85, { fill: C.card3 });
  s.addText([
    { text: "部署   ", options: { bold: true, color: C.or } },
    { text: "GitHub Actions · Nginx · systemd · 阿里云 ECS（详见 P13）" },
  ], { x: 0.78, y: 6.06, w: 5.6, h: 0.85, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "middle" });
  card(s, 6.76, 6.06, 6.07, 0.85, { fill: C.card3 });
  s.addText([
    { text: "工具链   ", options: { bold: true, color: C.or } },
    { text: "Maven · ZXing 二维码 · Lombok" },
    { text: "   ｜   缓存暂用 JVM 内存，Redis 规划中", options: { color: C.faint } },
  ], { x: 7.04, y: 6.06, w: 5.6, h: 0.85, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("技术选型的主线是「复用」。C 端为什么同时用 Flutter 和 uni-app？因为一套代码各出两个端：Flutter 出 Android 和 Web，uni-app 出微信小程序和 H5，四个客户端实际只有两份前端代码。后端选 Spring Boot 3 是因为 REST、WebSocket、SSE 三种通信能在一个技术栈里解决；MyBatis-Plus 的通用 CRUD 配合我写的基类，把十二个管理模块的接口代码压缩到接近零。AI 接入刻意没用任何大模型 SDK，直接按 OpenAI 兼容协议发 HTTP 请求，换模型只改配置。缓存层目前用 JVM 内存而不是 Redis，是有意的取舍，第 15 页会讲升级路线。");
})();

/* ============================================================ S6 数据库设计 */
(() => {
  const s = newSlide();
  header(s, "06", "数据库设计", "17 张表 · IM 链路设计含金量最高");

  function tbl(x, y, w, name, lines, hl) {
    card(s, x, y, w, 1.06, { fill: hl ? C.card2 : C.card });
    s.addText(name, { x: x + 0.18, y: y + 0.1, w: w - 0.3, h: 0.28, fontSize: 13, bold: true, color: C.orLt, fontFace: F, margin: 0 });
    s.addText(lines.map((l, i) => ({ text: l, options: { breakLine: i < lines.length - 1 } })),
      { x: x + 0.18, y: y + 0.42, w: w - 0.3, h: 0.58, fontSize: 11.5, color: C.mut, fontFace: F, margin: 0, paraSpaceAfter: 2 });
  }

  tbl(0.5, 1.42, 2.6, "sys_account", ["系统账号 + C 端用户", "uk_username · 角色字段"]);
  tbl(0.5, 2.92, 2.6, "order", ["uk_order_no · idx_status", "状态机 0→1→2→3"]);
  tbl(3.55, 1.42, 2.6, "store", ["门店 · 经纬度 · 营业时间", "客服按门店归属"], true);
  tbl(3.55, 2.92, 2.6, "customer_service", ["account_id + store_id", "客服-账号-门店双绑定"], true);
  tbl(6.6, 2.92, 2.0, "faq_knowledge", ["22 条种子知识", "keywords · hit_count"]);
  tbl(1.15, 4.62, 3.3, "im_session", ["uk sess_{userId}_{storeId}", "双未读计数 · AI / 人工类型"], true);
  tbl(5.0, 4.62, 3.3, "im_message", ["uk_client_msg_id 防重", "4 类发送方 · 已读标记"], true);

  arrowD(s, 1.8, 2.5, 2.9, C.faint, 1.5);
  s.addText("1:N", { x: 1.92, y: 2.56, w: 0.6, h: 0.26, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });
  arrowD(s, 4.85, 2.5, 2.9, C.faint, 1.5);
  s.addText("1:N", { x: 4.97, y: 2.56, w: 0.6, h: 0.26, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });
  arrowR(s, 4.5, 5.15, 4.98, C.or, 1.5);
  s.addText("1:N", { x: 4.52, y: 4.86, w: 0.44, h: 0.26, fontSize: 11.5, color: C.orLt, fontFace: F, margin: 0, align: "center" });
  s.addText("用户 × 门店 → 唯一会话（AI 与人工共享上下文）", { x: 1.15, y: 5.85, w: 7.4, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  // 右侧设计思路
  card(s, 8.95, 1.42, 3.88, 4.3);
  s.addText("设计思路", { x: 9.23, y: 1.62, w: 3.3, h: 0.32, fontSize: 14, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const ideas = [
    ["规范化建模", "逻辑外键 + 配套索引，避免物理外键锁表"],
    ["唯一键做业务幂等", "订单号 / 会话号 / 客户端消息号"],
    ["面向查询建索引", "状态过滤 · 按会话取消息 · 按接收方标已读"],
    ["双未读计数", "以少量冗余换两条高频查询路径"],
  ];
  ideas.forEach((d, i) => {
    const yy = 2.1 + i * 0.92;
    s.addShape(pres.shapes.OVAL, { x: 9.23, y: yy, w: 0.34, h: 0.34, fill: { color: C.card2 }, line: { color: C.or, width: 1 } });
    s.addText(String(i + 1), { x: 9.23, y: yy, w: 0.34, h: 0.34, align: "center", valign: "middle", fontSize: 12, bold: true, color: C.or, fontFace: F, margin: 0 });
    s.addText([
      { text: d[0], options: { bold: true, color: C.txt, breakLine: true } },
      { text: d[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 9.72, y: yy - 0.04, w: 3.0, h: 0.85, fontSize: 12.5, fontFace: F, margin: 0, paraSpaceAfter: 3 });
  });

  card(s, 0.5, 6.32, 12.33, 0.62, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "其余 11 张表   ", options: { bold: true, color: C.or } },
    { text: "category（parent_id 自关联树）· course · activity · video · article · ad / ad_position · favorite · user_address 等", options: { color: C.mut } },
  ], { x: 0.78, y: 6.32, w: 11.8, h: 0.62, fontSize: 12, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("数据库一共十七张表，我重点讲 IM 这条链路。会话表用「用户 ID 加门店 ID」拼成复合唯一键，保证一个用户对一个门店只有一个会话，AI 和人工共享上下文。消息表的客户端消息号唯一键是为了幂等：断线重连后重发同一条消息，数据库层面直接挡住重复落库，这是消息不重的基础。未读数做了用户、客服两个计数字段，属于反范式设计，用冗余换掉每次的 count 查询。订单表是典型的状态机加唯一订单号，金额用 DECIMAL 避免浮点误差。");
})();

/* ============================================================ S7 核心功能 */
(() => {
  const s = newSlide();
  header(s, "07", "核心功能实现", "AI 长在业务数据上，且永远可用");

  const feats = [
    {
      n: "①", t: "AI 育儿问答助手（FAQ × DeepSeek 双引擎）",
      need: "24h 在线育儿问答，业务问题不能答错",
      how: "意图识别 → FAQ 知识库优先（22 条 · keywords 匹配）→ DeepSeek 多轮（带 6 条历史）",
      eff: "高频问题毫秒级返回，大模型异常自动降级",
    },
    {
      n: "②", t: "客服 IM 实时会话 + AI 一键转人工",
      need: "AI 答不了时，无缝找到真人客服",
      how: "WebSocket /ws/im（JWT 握手 · 25s 心跳 · ACK）；三级调度：本店在线 → 本店 → 全平台",
      eff: "上下文无缝迁移，双端实时推送，可评价可切回",
    },
    {
      n: "③", t: "课程订单闭环（线上购买 → 线下核销）",
      need: "报名课程形成完整交易闭环",
      how: "下单 → 模拟支付（预留微信支付）→ ZXing 二维码 → 到场核销",
      eff: "订单状态机 0→1→2→3，杜绝脏状态",
    },
    {
      n: "④", t: "AI 个性化推荐「小宇宙计划」",
      need: "家长不会描述需求，系统要主动推",
      how: "宝宝年龄 + 兴趣 → 课程 4 · 活动 3 · 视频 3 + AI 推荐导语",
      eff: "内容分发从「人找内容」到「内容找人」",
    },
  ];
  feats.forEach((f, i) => {
    const x = 0.5 + (i % 2) * 6.27, y = 1.35 + Math.floor(i / 2) * 2.78;
    card(s, x, y, 6.06, 2.6);
    s.addText([
      { text: f.n + "  ", options: { color: C.or, bold: true } },
      { text: f.t, options: { bold: true, color: C.txt } },
    ], { x: x + 0.28, y: y + 0.18, w: 5.55, h: 0.34, fontSize: 14, fontFace: F, margin: 0 });
    kv(s, x + 0.28, y + 0.64, 5.55, "需求", f.need, C.blueLt, { h: 0.34 });
    kv(s, x + 0.28, y + 1.06, 5.55, "方案", f.how, C.orLt, { h: 0.66 });
    kv(s, x + 0.28, y + 1.82, 5.55, "效果", f.eff, C.green, { h: 0.34, color: C.green });
  });

  s.addNotes("挑四个核心功能讲。第一个 AI 问答，做法是三级漏斗：先识别是不是要转人工，再去 FAQ 知识库精确匹配——命中就不花大模型的钱、也是毫秒级返回；只有长尾问题才交给 DeepSeek，并且带着六轮上下文。第二个是转人工，这是全项目最有含金量的链路：AI 会话和人工会话是同一个 session，转接时按「本店在线、本店、全平台」三级挑客服，用户和客服两端同时收到推送，体验是无缝的。第三个是交易闭环，下单到扫码核销由订单状态机保证不会出现脏状态。第四个是个性化推荐，本质是让 AI 读平台真实业务数据来写推荐语。（建议本页配 4 张真实界面截图：AI 对话、客服工作台、订单核销、推荐结果）");
})();

/* ============================================================ S8 前端实现 */
(() => {
  const s = newSlide();
  header(s, "08", "前端实现", "三端同构：一套契约，三份实现");

  const cols = [
    ["Flutter App", "Android APK · Web", [
      "27 个页面 · 5 Tab 与小程序一一对应",
      "http 手写统一封装，约 45 个接口方法",
      "web_socket_channel 接入实时 IM",
      "11 个通用组件：骨架屏 / 空态 / 重试",
      "token 持久化 SharedPreferences",
    ]],
    ["uni-app 小程序 · H5", "一套代码双端发布", [
      "26 个页面 · 微信登录 · 扫码登录",
      "uni.request 封装 18 组 API",
      "IM 单例：ACK 确认 + 6s 重发 + 4s 重连",
      "realtime.js：SSE + 5s 版本号轮询兜底",
      "后台改内容，C 端自动刷新免发版",
    ]],
    ["Vue3 管理后台", "Element Plus + Vite", [
      "14 个视图 · 登录守卫 + 401 拦截",
      "ListPage.vue 483 行：配置式生成 CRUD",
      "axios 拦截器统一注入 Bearer token",
      "客服工作台：WS + FAQ 快捷回复",
      "WebAudio 提示音 · 标题栏未读数",
    ]],
  ];
  cols.forEach((c, i) => {
    const x = 0.5 + i * 4.17;
    card(s, x, 1.35, 3.98, 3.9);
    s.addText(c[0], { x: x + 0.26, y: 1.55, w: 3.5, h: 0.34, fontSize: 14.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
    s.addText(c[1], { x: x + 0.26, y: 1.92, w: 3.5, h: 0.28, fontSize: 11.5, color: C.orLt, fontFace: F, margin: 0 });
    s.addText(c[2].map((t, j) => ({ text: t, options: { bullet: bu(), breakLine: j < c[2].length - 1 } })),
      { x: x + 0.26, y: 2.36, w: 3.55, h: 2.75, fontSize: 12, color: C.txt, fontFace: F, margin: 0, paraSpaceAfter: 8, valign: "top" });
  });

  card(s, 0.5, 5.5, 12.33, 1.4, { fill: C.card3 });
  s.addText("三端一致性约定（跨端复用的根基）", { x: 0.82, y: 5.68, w: 6, h: 0.32, fontSize: 13.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  const cons = ["{code,msg,data} 统一信封", "JWT Bearer 认证", "401 清凭证跳登录", "同一 /ws/im 协议"];
  cons.forEach((t, i) => chip(s, 0.82 + i * 3.0, 6.12, 2.85, 0.55, t, { fs: 12.5, fill: C.card2 }));

  s.addNotes("前端最有价值的不是某个页面，而是「同构复用」的工程方法。三端遵循完全一致的契约：统一响应信封、统一 token 注入、统一 401 处理、同一套 WebSocket 协议——所以 Flutter 端和 uniapp 端的 IM 服务是逐行对应的两个实现。管理后台我把十二个几乎一样的列表页抽象成一个 483 行的 ListPage 通用组件，新页面只需要传列定义和表单字段，几十行配置就生成完整增删改查。C 端还做了内容实时同步：后台一改数据，家长端通过 SSE 或者版本号轮询自动刷新，这是「运营不依赖发版」的关键。");
})();

/* ============================================================ S9 后端实现 */
(() => {
  const s = newSlide();
  header(s, "09", "后端实现", "通用基类 + 统一协议，压住 108 个接口");

  card(s, 0.5, 1.35, 5.0, 5.55);
  s.addText("分层结构", { x: 0.8, y: 1.55, w: 3, h: 0.32, fontSize: 14, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const layers = [
    ["Controller × 20", "REST + WebSocket + SSE 入口"],
    ["Service × 20", "业务逻辑 · FAQ 匹配 · 客服调度"],
    ["Mapper × 17", "MyBatis-Plus · 分页插件"],
    ["MySQL 8.0", "17 张表"],
  ];
  layers.forEach((l, i) => {
    const yy = 2.02 + i * 0.82;
    chip(s, 1.05, yy, 3.9, 0.6, "", { fill: C.card2 });
    s.addText([
      { text: l[0] + "   ", options: { bold: true, color: C.orLt } },
      { text: l[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 1.05, y: yy, w: 3.9, h: 0.6, align: "center", valign: "middle", fontSize: 12.5, fontFace: F, margin: 0 });
    if (i < 3) arrowD(s, 3.0, yy + 0.62, yy + 0.8, C.faint, 1.5);
  });
  s.addText("横切能力", { x: 0.8, y: 5.42, w: 3, h: 0.3, fontSize: 13, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const cross = ["统一响应 R", "全局异常处理", "JWT + 30 白名单", "MP 分页插件"];
  cross.forEach((t, i) => {
    const col = i % 2, row = Math.floor(i / 2);
    chip(s, 0.8 + col * 2.1, 5.82 + row * 0.6, 1.95, 0.5, t, { fs: 11.5, fill: C.card2 });
  });

  card(s, 5.7, 1.35, 7.13, 5.55);
  s.addText([
    { text: "案例 1   ", options: { bold: true, color: C.or } },
    { text: "POST /api/ai/service-chat 全链路", options: { bold: true, color: C.txt } },
  ], { x: 6.0, y: 1.55, w: 6.5, h: 0.34, fontSize: 14.5, fontFace: F, margin: 0 });
  const steps = [
    "获取 / 创建会话，保存用户消息",
    "转人工意图识别 —— 命中即返回 needTransfer",
    "FAQ 检索 —— 命中直接返回，hit_count +1",
    "未命中 → DeepSeek（携带最近 6 条历史）",
    "异常捕获 → 降级兜底文案，AI 回复落库",
  ];
  steps.forEach((t, i) => {
    const yy = 2.06 + i * 0.72;
    s.addShape(pres.shapes.OVAL, { x: 6.0, y: yy, w: 0.4, h: 0.4, fill: { color: C.card2 }, line: { color: C.or, width: 1.25 } });
    s.addText(String(i + 1), { x: 6.0, y: yy, w: 0.4, h: 0.4, align: "center", valign: "middle", fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
    s.addText(t, { x: 6.56, y: yy + 0.02, w: 6.0, h: 0.4, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "top" });
  });
  card(s, 6.0, 5.78, 6.53, 0.88, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "案例 2   ", options: { bold: true, color: C.or } },
    { text: "POST /api/order/{id}/verify 核销 —— 校验状态 = 已支付 → 置已核销并记录时间，非法状态直接拒绝", options: { color: C.mut } },
  ], { x: 6.25, y: 5.78, w: 6.05, h: 0.88, fontSize: 12, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("后端是标准三层，但真正控制复杂度的是两个设计。第一是 CrudController 基类：管理端十二个模块本质上都是增删改查，我把分页、关键词搜索、状态筛选全部沉到基类，子类只声明实体和频道名，就自动获得四个接口，而且每次数据变更会自动推高版本号，驱动 C 端实时刷新。第二是统一协议：所有接口返回同一个信封，所有异常被全局处理器兜住，认证集中在拦截器加白名单。右边这条链路是 AI 客服接口的完整处理过程，从意图识别到 FAQ 到大模型再到降级，每一层都有明确的职责和出口。订单核销演示了状态机校验如何防止非法流转。");
})();

/* ============================================================ S10 技术难点 */
(() => {
  const s = newSlide();
  header(s, "10", "技术难点与解决方案", "四个真问题，用机制而非配置解决");

  const diffs = [
    {
      t: "AI 服务的质量 · 成本 · 可用性矛盾",
      p: "大模型慢 / 贵 / 不稳定，直接当客服不可用",
      sol: "FAQ 知识库前置 + 60s 超时 + 异常降级文案兜底",
      e: "高频问题毫秒级返回，主流程永不报错",
    },
    {
      t: "弱网下 WebSocket 消息的丢失与重复",
      p: "断网 / 锁屏断连，重连重发导致重复",
      sol: "ACK + clientMsgId 唯一键幂等 + 4s 自动重连 + 拉历史",
      e: "消息不丢 · 不重 · 会话状态可恢复",
    },
    {
      t: "AI → 人工的无缝转接",
      p: "会话在 AI 手里，上下文与归属需要迁移",
      sol: "会话状态机（AI / 人工）+ 三级客服调度 + WS 双端推送",
      e: "用户无感切换，客服响铃接入",
    },
    {
      t: "CI/CD 部署清空线上库（真实事故）",
      p: "schema 带 DROP TABLE，导入即清库",
      sol: "幂等初始化 + 表结构校验 + 10 份备份回滚",
      e: "自动部署零数据事故，分钟级回滚",
    },
  ];
  diffs.forEach((d, i) => {
    const x = 0.5 + (i % 2) * 6.27, y = 1.35 + Math.floor(i / 2) * 2.78;
    card(s, x, y, 6.06, 2.6);
    s.addText([
      { text: "0" + (i + 1) + "   ", options: { color: C.or, bold: true, fontSize: 17 } },
      { text: d.t, options: { bold: true, color: C.txt } },
    ], { x: x + 0.28, y: y + 0.16, w: 5.55, h: 0.36, fontSize: 13.5, fontFace: F, margin: 0 });
    kv(s, x + 0.28, y + 0.64, 5.55, "问题", d.p, C.red, { h: 0.34 });
    kv(s, x + 0.28, y + 1.08, 5.55, "方案", d.sol, C.blueLt, { h: 0.66 });
    kv(s, x + 0.28, y + 1.86, 5.55, "效果", d.e, C.green, { h: 0.34, color: C.green });
  });

  s.addNotes("这一页讲四个真问题。第一个是 AI 的可用性：大模型又慢又贵还不稳定，我的解法是让 FAQ 知识库挡在前面，命中就不进大模型，超时和异常全部降级成兜底文案，保证用户永远看不到报错。第二个是弱网下的消息可靠性：我设计了一套应用层确认机制，客户端消息号做幂等键，数据库唯一键兜底，重发也不怕重复；配合心跳、自动重连和拉历史，做到不丢不重。第三个是转人工：本质是一个会话状态机加三级客服调度，上下文无缝带走。第四个是最惊险的——早期部署脚本带着 DROP TABLE，会把线上库清空，发现后我把脚本改造成幂等的：已有数据绝不覆盖，还加了表结构校验、健康检查和十份备份回滚，从此自动部署零事故。");
})();

/* ============================================================ S11 安全设计 */
(() => {
  const s = newSlide();
  header(s, "11", "安全设计", "从认证到上传的六层防护");

  card(s, 0.5, 1.35, 7.55, 5.55);
  s.addText("已实现", { x: 0.82, y: 1.55, w: 3, h: 0.34, fontSize: 14.5, bold: true, color: C.green, fontFace: F, margin: 0 });
  const sec = [
    ["JWT 认证", "HS256 · 2h 有效期 · 密钥走环境变量"],
    ["BCrypt 密码", "加密存储 · 已加密检测防二次加密"],
    ["接口授权", "JwtInterceptor + 30 条方法级白名单 · 三种角色"],
    ["SQL 注入防护", "MyBatis-Plus 全预编译参数"],
    ["上传安全", "类型白名单 · UUID 重命名 · 200MB 上限"],
    ["敏感信息", "微信 / AI / 短信密钥全环境变量，仓库零明文"],
  ];
  sec.forEach((r, i) => {
    const yy = 2.08 + i * 0.8;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x: 0.82, y: yy, w: 0.3, h: 0.3, rectRadius: 0.05, fill: { color: "12332A" }, line: { color: C.green, width: 1 } });
    s.addText("✓", { x: 0.82, y: yy - 0.01, w: 0.3, h: 0.3, align: "center", valign: "middle", fontSize: 13, bold: true, color: C.green, fontFace: F, margin: 0 });
    s.addText([
      { text: r[0], options: { bold: true, color: C.txt } },
      { text: "  ——  " + r[1], options: { color: C.mut } },
    ], { x: 1.3, y: yy - 0.03, w: 6.5, h: 0.5, fontSize: 12.5, fontFace: F, margin: 0, valign: "top" });
  });

  card(s, 8.25, 1.35, 4.58, 5.55, { fill: C.card3 });
  s.addText("待改进（如实标注）", { x: 8.55, y: 1.55, w: 3.6, h: 0.34, fontSize: 14.5, bold: true, color: C.amber, fontFace: F, margin: 0 });
  const todo = [
    ["HTTPS 未启用", "当前 Nginx 仅 80 端口"],
    ["JWT 无刷新机制", "过期后需重新登录，体验有损"],
    ["权限粒度不足", "后台仅到登录态，缺按钮级 RBAC"],
  ];
  todo.forEach((r, i) => {
    const yy = 2.1 + i * 1.05;
    s.addShape(pres.shapes.OVAL, { x: 8.55, y: yy + 0.06, w: 0.1, h: 0.1, fill: { color: C.amber } });
    s.addText([
      { text: r[0], options: { bold: true, color: C.txt, breakLine: true } },
      { text: r[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 8.78, y: yy - 0.04, w: 3.75, h: 0.9, fontSize: 12.5, fontFace: F, margin: 0, paraSpaceAfter: 3 });
  });
  s.addText("不回避短板 —— 均已列入 P15 升级路线", { x: 8.55, y: 5.9, w: 4.0, h: 0.6, fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  s.addNotes("安全面我做了六层：JWT 认证且密钥走环境变量；BCrypt 存密码并防止重复加密；拦截器加方法级白名单控制公开接口范围；SQL 全部预编译；上传有类型白名单和 UUID 重命名，防止恶意文件和路径覆盖；所有第三方密钥只从环境变量注入，仓库里没有任何明文。同时如实说三个还没做的：HTTPS、token 刷新、按钮级 RBAC——我把它们列为下一阶段的明确事项，而不是回避。");
})();

/* ============================================================ S12 性能优化 */
(() => {
  const s = newSlide();
  header(s, "12", "性能优化", "优化做在机制上，不编造数字");

  const rows = [
    ["数据库", "高频查询针对性索引（状态 / 会话 / 已读标记）· 全接口强制分页，杜绝全表列表", false],
    ["AI 链路", "FAQ 前置 —— 高频问题不进大模型：秒级 → 毫秒级，且零 token 消耗", true],
    ["网络层", "Nginx 托管静态资源 · 版本号增量同步替代全量轮询 · Hikari 连接池调优", false],
    ["前端层", "图片缓存 + 骨架屏 · 分页加载 · 25s 心跳平衡实时性与耗电", false],
  ];
  rows.forEach((r, i) => {
    const yy = 1.4 + i * 1.06;
    card(s, 0.5, yy, 8.55, 0.92);
    chip(s, 0.74, yy + 0.21, 1.15, 0.5, r[0], { fs: 12.5, bold: true, fill: r[2] ? C.or : C.card2, color: r[2] ? "FFFFFF" : C.txt });
    s.addText(r[1], { x: 2.1, y: yy + 0.08, w: 5.35, h: 0.76, fontSize: 12.5, color: r[2] ? C.orLt : C.txt, fontFace: F, margin: 0, valign: "middle" });
    if (r[2]) chip(s, 7.55, yy + 0.28, 1.25, 0.36, "收益最大", { fs: 11, color: "FFFFFF", fill: "7C4A03", line: "7C4A03" });
  });

  card(s, 9.3, 1.4, 3.53, 4.18, { dash: "dash", line: C.strokeDash, fill: C.card3, noShadow: true });
  s.addText("压测数据 待补充", { x: 9.3, y: 2.15, w: 3.53, h: 0.4, align: "center", fontSize: 16, bold: true, color: C.mut, fontFace: F, margin: 0 });
  s.addText("建议：JMeter 压测分页接口与\nFAQ 接口，补充优化前后对比图表", { x: 9.5, y: 2.7, w: 3.13, h: 0.9, align: "center", fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  card(s, 0.5, 5.85, 12.33, 0.95, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "说明   ", options: { bold: true, color: C.or } },
    { text: "本页仅列已落地的优化机制，未虚构任何量化指标；答辩后可用 JMeter 数据替换右侧占位框。", options: { color: C.mut } },
  ], { x: 0.82, y: 5.85, w: 11.7, h: 0.95, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("性能上我做的都是设计层面的正确事，先如实说明：目前没有系统性压测数据，所以这页只讲机制不编数字。收益最大的是 AI 链路——让 FAQ 知识库挡在大模型前面，高频问题毫秒级返回还省了模型调用；数据库侧每个高频查询都配了索引、全接口强制分页；网络侧静态资源全部交给 Nginx，内容同步用版本号做增量感知而不是全量轮询。答辩后我计划用 JMeter 补一组前后对比数据，把这一页补成量化图表。");
})();

/* ============================================================ S13 部署与工程化 */
(() => {
  const s = newSlide();
  header(s, "13", "部署与工程化", "提交即上线 · 幂等部署 · 可回滚");

  const steps = [
    ["git push main", "触发流水线"],
    ["四路并行构建", "jar / admin / APK / Web"],
    ["rsync 上传", "自动备份 10 份"],
    ["幂等 DB 初始化", "已有表绝不清库"],
    ["重启服务", "systemd 守护"],
    ["双重校验", "健康检查 + 表结构"],
  ];
  steps.forEach((st, i) => {
    const x = 0.5 + i * 2.08;
    card(s, x, 1.5, 1.92, 1.62);
    s.addText(String(i + 1), { x: x + 0.16, y: 1.64, w: 0.5, h: 0.4, fontSize: 20, bold: true, color: C.or, fontFace: F, margin: 0 });
    s.addText([
      { text: st[0], options: { bold: true, color: C.txt, breakLine: true } },
      { text: st[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: x + 0.16, y: 2.12, w: 1.64, h: 0.9, fontSize: 12.5, fontFace: F, margin: 0, paraSpaceAfter: 4 });
    if (i < 5) arrowR(s, x + 1.94, 2.31, x + 2.06, C.or, 1.75);
  });

  card(s, 0.5, 3.55, 6.06, 1.75);
  s.addText("Nginx 单域名统一入口", { x: 0.82, y: 3.75, w: 5.4, h: 0.32, fontSize: 13.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText("/api 反代 3001 ｜ /ws 长连接升级 ｜ SSE 关缓冲\n/uploads 图片 ｜ /download APK 直链 + 下载二维码页", {
    x: 0.82, y: 4.16, w: 5.5, h: 0.95, fontSize: 12, color: C.mut, fontFace: F, margin: 0, paraSpaceAfter: 5,
  });
  card(s, 6.77, 3.55, 6.06, 1.75);
  s.addText("环境配置", { x: 7.09, y: 3.75, w: 5.4, h: 0.32, fontSize: 13.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText("数据库 / JWT / 微信 / AI / 短信密钥全部环境变量注入\ndev 与 prod 同构配置，仓库零明文", {
    x: 7.09, y: 4.16, w: 5.5, h: 0.95, fontSize: 12, color: C.mut, fontFace: F, margin: 0, paraSpaceAfter: 5,
  });

  card(s, 0.5, 5.62, 12.33, 1.3, { fill: C.card3 });
  s.addText("十几分钟\n全程无人值守", { x: 0.95, y: 5.78, w: 3.2, h: 1.0, fontSize: 20, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText("版本迭代从「每周发版」变成「随时发版」；保留 10 份历史备份，出问题分钟级回滚；进程宕机 systemd 5 秒自动拉起。", {
    x: 4.5, y: 5.78, w: 8.0, h: 1.0, fontSize: 13, color: C.txt, fontFace: F, margin: 0, valign: "middle",
  });

  s.addNotes("部署是这个项目工程化程度最高的部分。推一次代码，GitHub Actions 会并行构建四个产物：后端 jar、后台前端、安卓安装包和 Flutter Web，然后自动上传服务器——上传前先备份旧版本，保留十份随时回滚。数据库初始化是幂等的，绝不覆盖线上数据；重启后有两道验收：接口健康检查加数据库表结构校验，任何一道不过就判失败。运行期由 systemd 守护，进程挂了五秒内自动拉起。Nginx 把 API、WebSocket、SSE、图片、APK 下载全部收进一个域名。整套流程十几分钟，无人值守。");
})();

/* ============================================================ S14 项目成果 */
(() => {
  const s = newSlide();
  header(s, "14", "项目成果", "全部可核实的真实数字");

  const stats = [
    ["4", "个端", "App / 小程序 / H5 / 后台"],
    ["108", "个接口", "REST + WS + SSE"],
    ["17", "张表", "MySQL 8.0"],
    ["67", "个页面", "三端视图合计"],
    ["22", "条知识", "FAQ 知识库"],
    ["10", "份备份", "可分钟级回滚"],
  ];
  stats.forEach((st, i) => {
    const x = 0.5 + i * 2.08;
    card(s, x, 1.4, 1.92, 1.9, { fill: C.card3 });
    s.addText([
      { text: st[0], options: { fontSize: 38, bold: true, color: C.or } },
      { text: " " + st[1], options: { fontSize: 13, color: C.txt } },
    ], { x: x + 0.1, y: 1.62, w: 1.72, h: 0.8, align: "center", fontFace: F, margin: 0 });
    s.addText(st[2], { x: x + 0.1, y: 2.62, w: 1.72, h: 0.5, align: "center", fontSize: 11.5, color: C.mut, fontFace: F, margin: 0 });
  });

  const quals = [
    ["真实上线运行", "阿里云 ECS + systemd 守护 + Nginx 统一入口；Android 包扫码即装，不是 PPT 项目"],
    ["三端共享一套 API", "功能一次开发、多端可用；运营数据实时打通，新端接入成本趋近于零"],
    ["AI 长在业务数据上", "问答 / 推荐 / 转人工三条链路全部基于真实业务数据，含完整降级兜底"],
  ];
  quals.forEach((q, i) => {
    const x = 0.5 + i * 4.17;
    card(s, x, 3.7, 3.98, 2.3);
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x: x + 0.26, y: 3.96, w: 0.34, h: 0.34, rectRadius: 0.06, fill: { color: C.or } });
    s.addText("✓", { x: x + 0.26, y: 3.95, w: 0.34, h: 0.34, align: "center", valign: "middle", fontSize: 15, bold: true, color: "FFFFFF", fontFace: F, margin: 0 });
    s.addText(q[0], { x: x + 0.74, y: 3.94, w: 3.0, h: 0.38, fontSize: 14.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
    s.addText(q[1], { x: x + 0.26, y: 4.5, w: 3.45, h: 1.3, fontSize: 12, color: C.mut, fontFace: F, margin: 0, valign: "top" });
  });

  s.addText("以上数字均可在仓库代码中逐一核实（20 个 Controller / schema.sql / pages.json / pubspec）", {
    x: 0.5, y: 6.35, w: 11, h: 0.34, fontSize: 12, color: C.faint, fontFace: F, margin: 0,
  });

  s.addNotes("最后看成果，这些数字全部可以在代码里核实：四端加官网、一百零八个接口、十七张表、六十多个页面。但比数字更重要的是三件事：第一，它是真跑在云服务器上的生产系统，安卓包扫码可装；第二，三端共享一套 API，这个架构让后续任何新端的接入成本接近零；第三，AI 不是展示品，问答、推荐、转人工三条链路都长在真实业务数据上，并且有完整的降级兜底。工程上，我还建立了幂等部署、健康检查和回滚这套防事故机制。");
})();

/* ============================================================ S15 总结与未来规划 */
(() => {
  const s = newSlide();
  header(s, "15", "总结与未来规划", "完成度已闭环，规划对着短板来");

  card(s, 0.5, 1.35, 6.0, 5.55);
  s.addText("项目完成了什么", { x: 0.82, y: 1.55, w: 4, h: 0.34, fontSize: 14.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  dotRows(s, 0.82, 2.05, 5.4, [
    { t: "四端一体全链路：内容 → 咨询 → 交易 → 客服，真实上线", h: 0.6 },
    { t: "解决双边矛盾：家长信息焦虑 × 运营管理低效", h: 0.6 },
    { t: "全栈技术实践：Flutter · uni-app · Vue3 · Spring Boot 3 · MySQL · DeepSeek · CI/CD", h: 0.85 },
  ], { gap: 0.72, fs: 12.5 });
  s.addText("工程收获", { x: 0.82, y: 4.42, w: 4, h: 0.32, fontSize: 14.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  const gains = ["统一协议设计", "幂等与可靠性", "降级兜底思维", "防事故机制", "密钥管理"];
  gains.forEach((g, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    chip(s, 0.82 + col * 1.82, 4.88 + row * 0.62, 1.68, 0.5, g, { fs: 11.5, fill: C.card2 });
  });

  card(s, 6.7, 1.35, 6.13, 5.55);
  s.addText("未来规划 —— 每条对应一个真实短板", { x: 7.0, y: 1.55, w: 5.5, h: 0.34, fontSize: 14.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  const plan = [
    ["近期", "Redis 缓存外置 · HTTPS + 微信支付 · 自动化测试", "对应：单机内存态 / 明文传输 / 模拟支付 / 无单测"],
    ["中期", "@Valid 校验 + 事务 · RBAC + 数据看板 · FAQ 向量化 + 流式输出", "对应：手写校验 / 无图表 / FAQ 文本匹配"],
    ["远期", "Elasticsearch 搜索 · 消息队列削峰 · 监控告警体系", "对应：内容检索 / 高并发 / 可观测性"],
  ];
  plan.forEach((p, i) => {
    const yy = 2.1 + i * 1.55;
    chip(s, 7.0, yy, 0.95, 0.46, p[0], { fs: 12.5, bold: true, fill: C.card2, color: C.orLt });
    s.addText([
      { text: p[1], options: { color: C.txt, breakLine: true } },
      { text: p[2], options: { color: C.faint, fontSize: 11.5 } },
    ], { x: 8.15, y: yy - 0.04, w: 4.4, h: 1.3, fontSize: 12.5, fontFace: F, margin: 0, paraSpaceAfter: 5 });
    if (i < 2) arrowD(s, 7.47, yy + 0.5, yy + 1.05, C.strokeDash, 1.25);
  });

  s.addText([
    { text: "谢谢观看 · 欢迎提问      ", options: { bold: true, color: C.orLt, fontSize: 15 } },
    { text: "优童成长社 —— 把育儿服务数字化、智能化、可运营化", options: { color: C.mut, fontSize: 12.5 } },
  ], { x: 0.5, y: 7.02, w: 11, h: 0.36, fontSize: 13, fontFace: F, margin: 0 });

  s.addNotes("总结一下：这个项目完成了一个母婴服务平台从内容、咨询、交易到客服的全流程数字化，并且真实上线运行。技术上我完整实践了从 Flutter、uni-app、Vue3 三种前端，到 Spring Boot、MySQL、WebSocket、AI 接入，再到 CI/CD 和 Nginx 的全链路。更重要的是工程方法上的收获：统一协议、幂等设计、降级兜底、防事故部署。规划方面我不空谈——每一条都对着现在的真实短板：用 Redis 解决单机内存态、用 HTTPS 和真实支付补全交易合规、补自动化测试、把 FAQ 升级成向量检索。谢谢大家。");
})();

pres.writeFile({ fileName: "优童成长社-项目答辩PPT-15页精简版.pptx" }).then(() => console.log("DONE"));
