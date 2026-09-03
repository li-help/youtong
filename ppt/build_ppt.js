/* 优童成长社 · 全栈项目答辩 PPT 生成脚本（34 页扩展版）
 * 五幕结构：项目与需求 → 系统设计 → 核心实现 → 攻坚与加固 → 上线与收获
 * 深色科技风（#0B1220 底 + 品牌橙 #FF8F00）· 微软雅黑
 * 运行: node build_ppt.js
 */
const pptxgen = require("pptxgenjs");

const W = 13.33, H = 7.5, M = 0.5;
const F = "Microsoft YaHei";
const FC = "Consolas";
const TOTAL = "34";
const C = {
  bg: "0B1220", card: "141C2E", card2: "1A2540", card3: "0F1930", ghost: "16213A",
  stroke: "263349", strokeDash: "32456B",
  or: "FF8F00", orLt: "FFB84D",
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

function pageNum(s, idx) {
  s.addText(idx + " / " + TOTAL, { x: 12.05, y: 7.08, w: 0.78, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0, align: "right" });
}
function header(s, idx, kicker, title) {
  s.addText([
    { text: idx, options: { bold: true } },
    { text: "  ·  " + kicker },
  ], { x: M, y: 0.34, w: 9, h: 0.3, fontSize: 12, color: C.or, fontFace: F, margin: 0, charSpacing: 2 });
  s.addText(title, { x: M, y: 0.66, w: 11.9, h: 0.55, fontSize: 25, bold: true, color: C.txt, fontFace: F, margin: 0 });
  pageNum(s, idx);
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
function arrowBoth(s, x, y1, y2, color, wd) {
  s.addShape(pres.shapes.LINE, { x, y: y1, w: 0, h: y2 - y1, line: { color: color || C.faint, width: wd || 1.5, beginArrowType: "triangle", endArrowType: "triangle" } });
}

/* 分节页 */
function divider(s, num, title, question, items) {
  for (let i = 0; i < 5; i++) {
    const cur = i === num - 1;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x: 0.5 + i * 0.34, y: 0.5, w: 0.22, h: 0.22, rectRadius: 0.04,
      fill: { color: cur ? C.or : C.card2 }, line: { color: cur ? C.or : C.stroke, width: 0.75 },
    });
  }
  s.addText("0" + num, { x: 8.3, y: 1.35, w: 4.5, h: 4.9, fontSize: 230, bold: true, color: C.ghost, fontFace: F, margin: 0, align: "center", valign: "middle" });
  s.addText("PART " + num + " / 05", { x: 0.9, y: 2.12, w: 5, h: 0.34, fontSize: 14, bold: true, color: C.or, fontFace: F, margin: 0, charSpacing: 4 });
  s.addText(title, { x: 0.9, y: 2.52, w: 7.2, h: 0.8, fontSize: 36, bold: true, color: C.txt, fontFace: F, margin: 0 });
  s.addText("本部分回答 —— " + question, { x: 0.9, y: 3.52, w: 7.3, h: 0.4, fontSize: 15, bold: true, color: C.orLt, fontFace: F, margin: 0 });
  dotRows(s, 0.92, 4.18, 6.8, items, { gap: 0.52, fs: 13, color: C.mut });
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

/* ============================================================ S2 目录 */
(() => {
  const s = newSlide();
  s.addText("目录", { x: 0.5, y: 0.5, w: 4, h: 0.75, fontSize: 40, bold: true, color: C.txt, fontFace: F, margin: 0 });
  s.addText("CONTENTS ｜ 34 页 ｜ 建议时长 12~15 分钟 ｜ 重点：P16–23 · P25–28", {
    x: 0.5, y: 1.32, w: 11, h: 0.32, fontSize: 13, color: C.or, fontFace: F, margin: 0, charSpacing: 1,
  });
  const rows = [
    ["01", "项目与需求", "为什么做：双边痛点 · 应用场景与用户 · 功能全景 · 全链路业务流程", "P03 – 07"],
    ["02", "系统设计", "怎么设计：总体架构 · 三条通信通道 · 技术栈与选型取舍 · 数据库设计", "P08 – 14"],
    ["03", "核心实现", "怎么做：四大核心功能 · 前端三端同构 · 后端分层与 API 案例", "P15 – 23"],
    ["04", "攻坚与加固", "问题与解决：四大技术难点复盘 · 安全设计 · 性能优化", "P24 – 30"],
    ["05", "上线与收获", "效果如何：部署与工程化 · 项目成果 · 总结与未来规划", "P31 – 34"],
  ];
  rows.forEach((r, i) => {
    const yy = 1.95 + i * 1.0;
    s.addText(r[0], { x: 0.5, y: yy + 0.08, w: 1.0, h: 0.55, fontSize: 24, bold: true, color: C.or, fontFace: F, margin: 0 });
    s.addText(r[1], { x: 1.7, y: yy + 0.02, w: 6, h: 0.4, fontSize: 17, bold: true, color: C.txt, fontFace: F, margin: 0 });
    s.addText(r[2], { x: 1.7, y: yy + 0.46, w: 9.4, h: 0.34, fontSize: 12.5, color: C.mut, fontFace: F, margin: 0 });
    s.addText(r[3], { x: 11.2, y: yy + 0.12, w: 1.6, h: 0.32, fontSize: 12.5, color: C.faint, fontFace: F, margin: 0, align: "right" });
    if (i < 4) s.addShape(pres.shapes.LINE, { x: 0.5, y: yy + 0.94, w: 12.33, h: 0, line: { color: C.stroke, width: 0.75 } });
  });
  pageNum(s, "02");
  s.addNotes("整个汇报分五个部分，对应一条完整的问题链：为什么做、怎么设计、怎么实现、遇到什么问题怎么解决、最终效果如何。三十四页里最重要的是第三部分的四大核心功能和第四部分的四个技术难点，如果时间紧，我会优先保证这两部分讲透。");
})();

/* ============================================================ S3 分节 01 */
(() => {
  const s = newSlide();
  divider(s, 1, "项目与需求", "为什么值得做？", [
    "双边痛点：家长的「信息焦虑」× 运营的「管理低效」",
    "目标用户与一周真实使用场景",
    "功能全景：五大板块 + 12 个运营模块",
    "全链路业务流程：咨询、交易、同步三条主线",
  ]);
  pageNum(s, "03");
  s.addNotes("第一部分讲清楚这件事为什么值得做。我会先摆出家长和运营两边的真实痛点，再给出目标用户画像和一周的真实使用场景，最后用功能全景和业务流程说明系统的边界在哪里。");
})();

/* ============================================================ S4 项目背景 */
(() => {
  const s = newSlide();
  header(s, "04", "01 · 项目与需求", "家长的「信息焦虑」× 运营的「管理低效」");

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

/* ============================================================ S5 应用场景与目标用户 */
(() => {
  const s = newSlide();
  header(s, "05", "01 · 项目与需求", "目标用户画像与一周真实场景");

  card(s, 0.5, 1.35, 6.06, 2.35);
  s.addText([{ text: "家长", options: { color: C.or, bold: true } }, { text: "   C 端用户", options: { color: C.mut, fontSize: 12 } }],
    { x: 0.82, y: 1.55, w: 5.2, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  dotRows(s, 0.82, 2.0, 5.5, [
    "0~6 岁宝宝父母，时间碎片化、手机优先",
    "决策链：看到 → 咨询 → 报名 → 参与",
    "触点：微信小程序 / App / H5 三端",
    "核心诉求：找得到、问得清、买得顺",
  ], { gap: 0.42, fs: 12 });

  card(s, 6.77, 1.35, 6.06, 2.35);
  s.addText([{ text: "运营", options: { color: C.blueLt, bold: true } }, { text: "   B 端用户", options: { color: C.mut, fontSize: 12 } }],
    { x: 7.09, y: 1.55, w: 5.2, h: 0.32, fontSize: 14.5, fontFace: F, margin: 0 });
  dotRows(s, 7.09, 2.0, 5.5, [
    "非技术背景的运营 / 客服人员",
    "日常：内容上架 · 订单核销 · 客服接待",
    "触点：Vue3 管理后台（14 个视图）",
    "核心诉求：不写代码完成全部运营",
  ], { gap: 0.42, fs: 12, dot: C.blue });

  s.addText("一周真实场景", { x: 0.5, y: 3.98, w: 4, h: 0.32, fontSize: 13.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  const scenes = [
    ["周一 晚", "AI 育儿问答", "「宝宝 1 岁 3 个月还不会走路正常吗？」—— FAQ / 大模型秒级应答，24h 在线"],
    ["周三", "课程下单", "浏览早教课 → 在线下单支付 → 自动生成核销二维码，无需电话确认"],
    ["周六", "到店核销", "到场出示二维码 → 客服工作台一键核销 → 参与课程，订单状态闭环"],
    ["全程", "内容同步", "运营在后台上架新课 / 换 Banner → 家长端自动刷新，无需发版"],
  ];
  scenes.forEach((sc, i) => {
    const x = 0.5 + i * 3.13;
    card(s, x, 4.42, 2.98, 2.28);
    chip(s, x + 0.24, 4.62, 1.05, 0.4, sc[0], { fs: 11.5, color: C.orLt, fill: C.card3 });
    s.addText(sc[1], { x: x + 0.24, y: 5.12, w: 2.5, h: 0.34, fontSize: 13.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
    s.addText(sc[2], { x: x + 0.24, y: 5.5, w: 2.55, h: 1.1, fontSize: 12, color: C.mut, fontFace: F, margin: 0, valign: "top" });
  });

  s.addNotes("再看用户和场景。家长是 0 到 6 岁宝宝的父母，时间碎片化、以手机为主，决策链是看到、咨询、报名、参与；运营端是非技术背景的运营和客服，诉求是不写代码完成全部日常工作。下面这条时间线是真实跑起来的场景：周一晚上问 AI 育儿问题，周三下单课程拿到二维码，周六到店扫码核销，而这期间运营上架的任何新内容，家长端都会自动刷新——这就是这个产品的日常运转方式。");
})();

/* ============================================================ S6 需求分析与功能概览 */
(() => {
  const s = newSlide();
  header(s, "06", "01 · 项目与需求", "两类角色 · 五大板块 · 12 个运营模块");

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

/* ============================================================ S7 核心业务流程 */
(() => {
  const s = newSlide();
  header(s, "07", "01 · 项目与需求", "全链路业务流程：三条主线");

  const lanes = [
    {
      name: "家长侧", dot: C.or, y: 1.4,
      steps: ["发现内容", "AI 咨询", "转人工", "收藏下单"],
      cap: "咨询由「意图 → FAQ → 大模型」三级漏斗承接，转人工上下文无缝带走",
    },
    {
      name: "交易闭环", dot: C.green, y: 3.05,
      steps: ["下单支付", "生成二维码", "到场核销", "全程可查"],
      cap: "订单状态机 0 → 1 → 2 → 3 保证不出现脏状态，核销闭环沉淀真实运营数据",
    },
    {
      name: "运营侧", dot: C.blue, y: 4.7,
      steps: ["后台管理", "版本号变更", "推送同步", "自动刷新"],
      cap: "CrudController 变更自动推高频道版本号，SSE / 轮询驱动 C 端免发版刷新",
    },
  ];
  lanes.forEach((ln) => {
    card(s, 0.5, ln.y, 12.33, 1.5);
    chip(s, 0.78, ln.y + 0.35, 1.1, 0.5, ln.name, { fs: 12.5, bold: true, fill: C.card3, color: ln.dot });
    ln.steps.forEach((t, i) => {
      const bx = 2.15 + i * 2.72;
      chip(s, bx, ln.y + 0.24, 2.3, 0.62, t, { fs: 13, bold: true, fill: C.card2 });
      if (i < 3) arrowR(s, bx + 2.34, ln.y + 0.55, bx + 2.68, ln.dot, 1.75);
    });
    s.addText(ln.cap, { x: 2.15, y: ln.y + 1.02, w: 10.3, h: 0.34, fontSize: 12, color: C.mut, fontFace: F, margin: 0 });
  });

  card(s, 0.5, 6.35, 12.33, 0.62, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "贯穿三线   ", options: { bold: true, color: C.or } },
    { text: "同一账号体系 · 同一个 MySQL · 三端实时一致（REST + WebSocket + SSE）", options: { color: C.txt } },
  ], { x: 0.82, y: 6.35, w: 11.6, h: 0.62, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("把需求串成流程就是三条主线。第一条是家长侧：从发现内容、AI 咨询到转人工、收藏下单——注意咨询这一步由三级漏斗承接，能自动答的自动答，需要人的无缝转人工。第二条是交易闭环：下单支付、生成二维码、到场核销、全程可查，由订单状态机兜底。第三条是运营侧：后台的每一次管理动作都会推高数据版本号，通过 SSE 或轮询让家长端自动刷新。三条线跑在同一个账号体系和同一个数据库上，这就是「一个平台」的含义。");
})();

/* ============================================================ S8 分节 02 */
(() => {
  const s = newSlide();
  divider(s, 2, "系统设计", "系统是怎么设计的？", [
    "总体架构：一套后端服务四端，REST / WebSocket / SSE 三条通道",
    "技术栈全景与五个关键选型的「理由 + 代价」",
    "数据库：17 张表分域管理，IM 链路是设计含金量最高的部分",
  ]);
  pageNum(s, "08");
  s.addNotes("第二部分讲设计。先看总体架构和三条通信通道的分工，再说技术栈——我不打算罗列名词，而是讲五个关键选型各自的理由和付出的代价，最后落到数据库：十七张表怎么分域，IM 这条链路为什么是最有设计含金量的部分。");
})();

/* ============================================================ S9 系统整体架构 */
(() => {
  const s = newSlide();
  header(s, "09", "02 · 系统设计", "一套后端服务四端 · REST / WebSocket / SSE 三条通道");

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

  const chans = [
    ["REST  × 108 接口  ↓", C.blueLt],
    ["WebSocket  /ws/im 实时 IM  ↓", C.green],
    ["SSE  /api/sync/stream 内容同步  ↓", C.orLt],
  ];
  chans.forEach((cn, i) => {
    const cx = 2.1 + i * 3.61;
    chip(s, cx, 2.4, 3.3, 0.5, cn[0], { fs: 12, color: cn[1], fill: C.card3, line: C.strokeDash, bold: true });
  });

  card(s, 0.5, 3.1, 12.33, 0.82);
  s.addText("接入层", { x: 0.78, y: 3.32, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText("Nginx：/api 反代 3001 ｜ /ws 协议升级 · 3600s ｜ SSE 关缓冲 ｜ 静态托管 uploads / H5 / Web / APK 下载", {
    x: 2.1, y: 3.1, w: 10.5, h: 0.82, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "middle",
  });

  card(s, 0.5, 4.06, 12.33, 1.14);
  s.addText("应用层", { x: 0.78, y: 4.42, w: 1.15, h: 0.4, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  s.addText([
    { text: "Spring Boot 3.2.5（Java 17）：Controller ×20 → Service ×20 → Mapper ×17，CrudController 基类复用 12 个模块", options: { breakLine: true } },
    { text: "JWT 拦截器 + 30 条白名单 ｜ 统一响应 R{code,msg,data} ｜ 全局异常处理 ｜ WebSocket /ws/im 端点", options: { color: C.mut } },
  ], { x: 2.1, y: 4.18, w: 10.5, h: 0.92, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, paraSpaceAfter: 5, valign: "middle" });

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

  card(s, 0.5, 6.3, 12.33, 0.66, { dash: "dash", line: C.strokeDash, noShadow: true, fill: C.card3 });
  s.addText([
    { text: "外部服务   ", options: { bold: true, color: C.or } },
    { text: "DeepSeek 大模型（OpenAI 兼容协议）· 阿里云短信 · 微信开放能力（登录 / 小程序码）", options: { color: C.txt } },
    { text: "    密钥全部环境变量注入", options: { color: C.faint, fontSize: 11.5 } },
  ], { x: 2.1, y: 6.3, w: 10.5, h: 0.66, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("这是整体架构。最上面四个端共用同一套 REST API 和同一个数据库，功能开发一次、四端同时可用。中间 Nginx 是统一入口，托管的不只是 API，还有 WebSocket 长连接和 SSE 流。应用层是标准三层，二十个 Controller 对应二十个 Service。往下是 MySQL 十七张表加本地文件存储。三条通道分工明确：REST 管请求响应，WebSocket 管客服实时消息，SSE 管内容变更推送——后台改了内容，家长端自动刷新，不需要发版。如实说明：验证码、在线状态、版本号暂存 JVM 内存，Redis 在规划中。");
})();

/* ============================================================ S10 三条通信通道 */
(() => {
  const s = newSlide();
  header(s, "10", "02 · 系统设计", "三条通信通道：各司其职，互不替代");

  const cols = [
    {
      name: "REST", tag: "× 108 接口", color: C.blueLt, rows: [
        ["模式", "请求 - 响应"],
        ["场景", "全部业务读写：列表 / 详情 / 下单 / 管理"],
        ["鉴权", "JWT 拦截器 + 30 条方法级白名单"],
        ["约定", "统一信封 {code, msg, data}"],
      ],
    },
    {
      name: "WebSocket", tag: "/ws/im", color: C.green, rows: [
        ["模式", "全双工长连接"],
        ["场景", "客服 IM 实时收发（用户 ↔ 客服）"],
        ["鉴权", "握手解析 JWT · 客服上下线同步"],
        ["保活", "25s 心跳 · Nginx 3600s"],
        ["可靠", "ACK + clientMsgId 幂等 + 4s 重连"],
      ],
    },
    {
      name: "SSE", tag: "/api/sync/stream", color: C.orLt, rows: [
        ["模式", "服务端单向推送"],
        ["场景", "内容变更通知（课程 / banner 频道）"],
        ["实现", "DataVersionService 纯 JUC，不依赖 WebFlux"],
        ["兜底", "非 H5 端 5s 轮询版本号"],
      ],
    },
  ];
  cols.forEach((c, i) => {
    const x = 0.5 + i * 4.17;
    card(s, x, 1.35, 3.98, 4.35);
    s.addText([
      { text: c.name + "  ", options: { bold: true, color: c.color, fontSize: 16 } },
      { text: c.tag, options: { color: C.faint, fontSize: 12 } },
    ], { x: x + 0.26, y: 1.55, w: 3.5, h: 0.36, fontFace: F, margin: 0 });
    c.rows.forEach((r, j) => {
      const yy = 2.08 + j * 0.68;
      s.addText(r[0], { x: x + 0.26, y: yy, w: 0.72, h: 0.3, fontSize: 12, bold: true, color: c.color, fontFace: F, margin: 0 });
      s.addText(r[1], { x: x + 1.0, y: yy, w: 2.8, h: 0.6, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "top" });
    });
  });

  card(s, 0.5, 5.95, 12.33, 1.05, { fill: C.card3 });
  s.addText([
    { text: "为什么三种并存   ", options: { bold: true, color: C.or, fontSize: 13.5 } },
    { text: "REST 覆盖一切「请求-响应」最通用；双向实时只有 WebSocket 能做；内容同步只需单向广播 —— SSE 更轻、浏览器 EventSource 自带重连，并为小程序 / App 保留轮询兜底，三者是分工而不是堆叠。", options: { color: C.txt } },
  ], { x: 0.82, y: 5.95, w: 11.7, h: 1.05, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("很多人问我为什么要三条通道。REST 负责所有请求响应式的业务读写，这一百零八个接口覆盖了绝大部分功能。但客服聊天是双向实时的，只有 WebSocket 能做，为此我做了握手鉴权、心跳保活和一整套可靠性机制。而内容同步其实是单向广播——后台改了数据通知前端一下就行，用 SSE 比 WebSocket 更轻，浏览器 EventSource 自带重连，小程序和 App 这些不支持 SSE 的环境就用五秒轮询版本号兜底。所以三者是分工关系，不是技术堆砌。");
})();

/* ============================================================ S11 技术栈 */
(() => {
  const s = newSlide();
  header(s, "11", "02 · 系统设计", "每项技术都为解决具体问题");

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
    { text: "GitHub Actions · Nginx · systemd · 阿里云 ECS（详见 P32）" },
  ], { x: 0.78, y: 6.06, w: 5.6, h: 0.85, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "middle" });
  card(s, 6.76, 6.06, 6.07, 0.85, { fill: C.card3 });
  s.addText([
    { text: "工具链   ", options: { bold: true, color: C.or } },
    { text: "Maven · ZXing 二维码 · Lombok" },
    { text: "   ｜   缓存暂用 JVM 内存，Redis 规划中", options: { color: C.faint } },
  ], { x: 7.04, y: 6.06, w: 5.6, h: 0.85, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("技术选型的主线是「复用」。C 端为什么同时用 Flutter 和 uni-app？因为一套代码各出两个端：Flutter 出 Android 和 Web，uni-app 出微信小程序和 H5，四个客户端实际只有两份前端代码。后端选 Spring Boot 3 是因为 REST、WebSocket、SSE 三种通信能在一个技术栈里解决；MyBatis-Plus 的通用 CRUD 配合我写的基类，把十二个管理模块的接口代码压缩到接近零。AI 接入刻意没用任何大模型 SDK，直接按 OpenAI 兼容协议发 HTTP 请求，换模型只改配置。缓存层目前用 JVM 内存而不是 Redis，是有意的取舍，下一页展开讲。");
})();

/* ============================================================ S12 关键选型与取舍 */
(() => {
  const s = newSlide();
  header(s, "12", "02 · 系统设计", "关键选型：理由 + 代价，不回避");

  const rows = [
    ["Flutter + uni-app 双框架", "单一跨端框架 / 双端原生",
      "一套代码 × 2 覆盖四端，覆盖人群最大化",
      "双端逻辑需契约对齐 → 同一 WS 协议 + 同一 API 封装（见 P20）"],
    ["MyBatis-Plus 3.5.7", "Spring Data JPA",
      "通用 CRUD + 分页插件贴合管理端密集增删改查",
      "复杂查询需手写 SQL（本项目的查询都不复杂）"],
    ["手写 JWT（HS256）", "Spring Security 全家桶",
      "轻量可控，完整掌握签名 / 校验 / 过期机制",
      "无刷新令牌、无按钮级权限 → 列入 P34 规划"],
    ["JVM 内存态", "一开始就引入 Redis",
      "单机部署下验证码 / ticket 生命周期短，内存方案够用",
      "重启丢失、无法水平扩展 → 收敛在独立类，可无痛替换"],
    ["OpenAI 兼容协议直调", "大模型官方 SDK",
      "供应商解耦，换模型只改 base-url / model 配置",
      "自行处理超时与解析 → 已封装 + 降级兜底"],
  ];
  rows.forEach((r, i) => {
    const yy = 1.35 + i * 1.08;
    card(s, 0.5, yy, 12.33, 1.0);
    s.addText([
      { text: r[0], options: { bold: true, color: C.txt, fontSize: 13.5, breakLine: true } },
      { text: "而非 " + r[1], options: { color: C.faint, fontSize: 12 } },
    ], { x: 0.78, y: yy + 0.14, w: 4.3, h: 0.75, fontFace: F, margin: 0, paraSpaceAfter: 4 });
    s.addText([
      { text: r[2], options: { color: C.txt, breakLine: true } },
      { text: "代价：" + r[3], options: { color: C.faint, fontSize: 11.5 } },
    ], { x: 5.35, y: yy + 0.14, w: 7.2, h: 0.75, fontSize: 12.5, fontFace: F, margin: 0, paraSpaceAfter: 4 });
  });

  s.addNotes("这一页讲五个关键选型，每个都讲理由也讲代价。第一，Flutter 加 uni-app 双框架而不是单框架，因为一套代码乘以二覆盖四个端，代价是双端逻辑要靠契约对齐，下一部分会看到我怎么做。第二，MyBatis-Plus 而不是 JPA，因为管理后台全是密集增删改查，通用 CRUD 加分页插件正合适。第三，JWT 是手写的 HS256，为的是完全掌握令牌机制，代价是没有刷新和细粒度权限，已列入规划。第四，最容易被追问的：为什么没有 Redis——单机部署下验证码这些数据生命周期只有五分钟，内存方案够用，而且我把它们收敛在独立类里，换 Redis 不动上层。第五，AI 直调 OpenAI 兼容协议，供应商随时可换。");
})();

/* ============================================================ S13 数据库总览 */
(() => {
  const s = newSlide();
  header(s, "13", "02 · 系统设计", "数据库总览：17 张表，四个域");

  function group(x, y, w, h, title, count, chips_, note, cols) {
    const nc = cols || 2, cw = nc === 2 ? 2.55 : 1.32, cg = nc === 2 ? 0.15 : 0.06;
    card(s, x, y, w, h);
    s.addText([
      { text: title, options: { bold: true, color: C.orLt, fontSize: 13.5 } },
      { text: "   ·   " + count + " 张", options: { color: C.mut, fontSize: 12 } },
    ], { x: x + 0.28, y: y + 0.18, w: w - 0.5, h: 0.32, fontFace: F, margin: 0 });
    chips_.forEach((t, i) => {
      const col = i % nc, row = Math.floor(i / nc);
      chip(s, x + 0.28 + col * (cw + cg), y + 0.62 + row * 0.56, cw, 0.46, t, { fs: 12, fill: C.card2 });
    });
    if (note) s.addText(note, { x: x + 0.28, y: y + 1.78, w: w - 0.56, h: 0.5, fontSize: 12, color: C.mut, fontFace: F, margin: 0 });
  }

  group(0.5, 1.35, 6.06, 2.4, "账号与用户", 4, ["sys_account", "user", "favorite", "user_address"]);
  group(6.77, 1.35, 6.06, 2.4, "客服与智能", 4, ["customer_service", "faq_knowledge", "im_session", "im_message"]);
  group(0.5, 3.95, 6.06, 2.4, "内容生态", 8, ["store", "category", "ad_position", "ad", "video", "course", "activity", "article"], null, 4);
  group(6.77, 3.95, 6.06, 2.4, "交易闭环", 1, ["order"], "状态机：0 待支付 → 1 已支付 → 2 已核销 → 3 已取消\n金额 DECIMAL(10,2) · uk_order_no · paid_at / verify_at");

  card(s, 0.5, 6.55, 12.33, 0.55, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "设计约定   ", options: { bold: true, color: C.or } },
    { text: "InnoDB · utf8mb4 ｜ 逻辑外键 + 配套索引 ｜ 幂等唯一键（订单号 / 会话号 / 消息号）｜ 金额一律 DECIMAL", options: { color: C.txt } },
  ], { x: 0.82, y: 6.55, w: 11.7, h: 0.55, fontSize: 12, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("数据库十七张表，按职责分四个域。账号域四个表：系统账号同时充当 C 端用户表，加上收藏和收货地址。客服与智能域四个表是这个项目设计含金量最高的部分——客服表把后台账号和门店双向绑定，FAQ 知识库支撑 AI 问答，IM 会话和消息表支撑实时客服。内容域八个表是课程、活动、视频、文章、门店、分类和广告。交易域就一个订单表，但是带完整的状态机。底部是贯穿全部表的设计约定：InnoDB 加 utf8mb4、逻辑外键配索引、幂等唯一键、金额一律 DECIMAL。下一页展开 ER 关系。");
})();

/* ============================================================ S14 核心ER 与会话状态机 */
(() => {
  const s = newSlide();
  header(s, "14", "02 · 系统设计", "核心 ER 关系 · IM 链路设计含金量最高");

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

  card(s, 0.5, 6.18, 12.33, 0.85, { fill: C.card3, noShadow: true });
  s.addText("会话状态机", { x: 0.78, y: 6.28, w: 1.5, h: 0.6, fontSize: 12.5, bold: true, color: C.or, fontFace: F, margin: 0, valign: "middle" });
  const st = ["AI 接待（type 1）", "人工接待（type 2）", "切回 AI（type 1）"];
  st.forEach((t, i) => {
    const bx = 2.4 + i * 2.85;
    chip(s, bx, 6.36, 2.1, 0.5, t, { fs: 12, fill: C.card2, color: i === 1 ? C.green : C.txt, bold: i === 1 });
    if (i < 2) {
      arrowR(s, bx + 2.14, 6.61, bx + 2.81, C.or, 1.5);
      s.addText(i === 0 ? "转人工" : "结束", { x: bx + 2.1, y: 6.24, w: 0.75, h: 0.26, fontSize: 11.5, color: C.orLt, fontFace: F, margin: 0, align: "center" });
    }
  });
  s.addText("评分 1~5 写回 rating\n转接插入 transfer_notice", { x: 10.6, y: 6.3, w: 2.1, h: 0.62, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0, valign: "middle" });

  s.addNotes("ER 层面我重点讲 IM 这条链路。会话表用「用户 ID 加门店 ID」拼成复合唯一键，保证一个用户对一个门店只有一个会话，AI 和人工共享这个上下文——这是后面转人工能够无缝的根本原因。消息表的客户端消息号唯一键做幂等，断线重发也不会重复落库。未读数做了用户、客服双计数，属于反范式取舍，用冗余换掉高频的 count 查询。底部是会话状态机：AI 接待、转人工、结束切回 AI，全程同一个会话，评分直接写回会话表。");
})();

/* ============================================================ S15 分节 03 */
(() => {
  const s = newSlide();
  divider(s, 3, "核心实现", "关键功能是怎么做出来的？", [
    "四大核心功能：AI 问答 · 实时客服 IM · 订单闭环 · 个性化推荐",
    "前端：三端同构 + 两套「配置驱动」的复用抽象",
    "后端：分层与统一协议，两个代表性 API 案例拆解",
  ]);
  pageNum(s, "15");
  s.addNotes("第三部分是全场分量最重的：四大核心功能逐个拆开讲，每个都按需求、方案、效果展开；然后前端、后端各用两页，前端讲三端同构和复用抽象，后端讲分层协议和两个有代表性的 API 案例。");
})();

/* ============================================================ S16 功能① AI 育儿问答助手 */
(() => {
  const s = newSlide();
  header(s, "16", "03 · 核心实现", "功能①  AI 育儿问答助手：三级应答漏斗");

  card(s, 0.5, 1.35, 7.45, 5.55);
  s.addText("应答链路 —— 层级越靠上越快、越可控", { x: 0.8, y: 1.55, w: 6.5, h: 0.32, fontSize: 13.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const stages = [
    ["① 意图识别（正则匹配）", "转人工 / 人工客服 / 投诉 … → 直接返回 needTransfer", C.red],
    ["② FAQ 知识库检索优先", "22 条 · 7 类 · keywords 分词包含匹配 → 命中直接返回，不调大模型", C.green],
    ["③ DeepSeek 多轮生成", "携带最近 6 条历史 · temperature 0.7 · max_tokens 500 · ≤200 字", C.blueLt],
  ];
  stages.forEach((st, i) => {
    const yy = 2.05 + i * 1.32;
    card(s, 0.8, yy, 6.85, 1.05, { fill: C.card2, noShadow: true });
    s.addText([
      { text: st[0], options: { bold: true, color: st[2], fontSize: 13, breakLine: true } },
      { text: st[1], options: { color: C.mut, fontSize: 12 } },
    ], { x: 1.05, y: yy + 0.14, w: 6.4, h: 0.8, fontFace: F, margin: 0, paraSpaceAfter: 4 });
    if (i < 2) {
      arrowD(s, 2.4, yy + 1.07, yy + 1.3, C.faint, 1.5);
      s.addText("未命中", { x: 2.55, y: yy + 1.02, w: 1.0, h: 0.3, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });
    }
  });
  s.addShape(pres.shapes.OVAL, { x: 0.82, y: 6.08, w: 0.1, h: 0.1, fill: { color: C.amber } });
  s.addText("任意一步异常 → 固定话术兜底并引导转人工 —— 功能永远可用", {
    x: 1.05, y: 5.94, w: 6.6, h: 0.4, fontSize: 12.5, color: C.amber, fontFace: F, margin: 0,
  });

  card(s, 8.15, 1.35, 4.68, 5.55);
  const secs = [
    ["需求", C.blueLt, ["24h 在线育儿问答，解答喂养 / 发育问题", "平台业务口径必须准确", "响应要快，成本要可控"]],
    ["降级", C.amber, ["大模型超时 / 异常 → 固定话术引导转人工", "推荐接口 → 模板文案兜底"]],
    ["效果", C.green, ["高频问题 = 单次 DB 查询，毫秒级返回", "长尾问题大模型兜底，口径可控", "主流程永不报错（定性描述，无虚构指标）"]],
  ];
  let sy = 1.6;
  secs.forEach((sec) => {
    s.addText(sec[0], { x: 8.45, y: sy, w: 2, h: 0.3, fontSize: 13, bold: true, color: sec[1], fontFace: F, margin: 0 });
    sy += 0.4;
    sec[2].forEach((t, j) => {
      s.addShape(pres.shapes.OVAL, { x: 8.47, y: sy + 0.08, w: 0.09, h: 0.09, fill: { color: sec[1] } });
      s.addText(t, { x: 8.69, y: sy, w: 3.95, h: 0.5, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "top" });
      sy += 0.44;
    });
    sy += 0.28;
  });

  s.addNotes("第一个核心功能，AI 育儿问答。链路是一个三级漏斗：第一级用正则识别转人工类意图，命中就直接转接；第二级查 FAQ 知识库，二十二条种子知识按七类组织，用关键词分词做包含匹配，命中就毫秒级返回，完全不花大模型的钱；第三级才是 DeepSeek，带最近六轮历史生成两百字以内的回答。每一级都有降级出口，大模型挂了就返回固定话术引导转人工。对家长这是一个二十四小时在线的育儿顾问，对运营这是降低人工咨询成本的关键。");
})();

/* ============================================================ S17 功能② 客服 IM 实时会话 */
(() => {
  const s = newSlide();
  header(s, "17", "03 · 核心实现", "功能②  客服 IM 实时会话：WebSocket 全链路");

  card(s, 0.5, 1.35, 4.7, 5.55);
  s.addText("实时链路", { x: 0.8, y: 1.55, w: 3, h: 0.32, fontSize: 13.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const chain = [
    ["家长端", "uniapp / Flutter 同一协议"],
    ["WS /ws/im", "Nginx 升级 · JWT 握手"],
    ["后端", "在线池 · 落库 · 路由转发"],
    ["客服工作台", "Vue3 · 会话列表 · 未读角标"],
  ];
  chain.forEach((c, i) => {
    const yy = 2.05 + i * 1.14;
    card(s, 1.05, yy, 3.6, 0.72, { fill: C.card2, noShadow: true });
    s.addText([
      { text: c[0], options: { bold: true, color: i === 2 ? C.orLt : C.txt, breakLine: true } },
      { text: c[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 1.05, y: yy, w: 3.6, h: 0.72, align: "center", valign: "middle", fontSize: 12.5, fontFace: F, margin: 0 });
    if (i < 3) arrowBoth(s, 2.85, yy + 0.74, yy + 1.12, C.or, 1.5);
  });

  card(s, 5.4, 1.35, 7.43, 5.55);
  s.addText("消息协议与关键特性", { x: 5.7, y: 1.55, w: 5, h: 0.32, fontSize: 13.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const proto = ["chat 收发", "ACK 回执", "ping · pong", "read 已读", "transfer 转接", "close · rate"];
  proto.forEach((t, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    chip(s, 5.7 + col * 2.36, 2.05 + row * 0.62, 2.2, 0.5, t, { fs: 12, fill: C.card3, color: C.orLt });
  });
  dotRows(s, 5.72, 3.5, 6.9, [
    "握手鉴权：JWT 随连接携带；客服上下线自动同步 online 字段",
    "双未读计数：im_session 计数字段 + im_message.is_read 批量标记",
    "可靠传输：clientMsgId 幂等 · ACK 6s 超时可重试 · 4s 自动重连",
    "客服工作台：FAQ 快捷回复 · Ctrl+Enter 发送 · WebAudio 提示音",
    "会话收尾：客服结束切回 AI 接待；用户评分 1~5 写回会话",
  ], { gap: 0.62, fs: 12, h: 0.55 });

  s.addNotes("第二个功能，实时客服。左边是链路：家长端无论是 uniapp 还是 Flutter，走同一个 WebSocket 协议，经 Nginx 升级连到后端，后端维护在线连接池，消息先落库再路由，另一头是管理后台的客服工作台。右边是协议和特性：六种消息类型，其中 ACK 回执和 ping 心跳是可靠性的基础；未读数做了两层，会话表上的计数字段给角标用，消息表的已读标记做批量核销；工作台还配了 FAQ 快捷回复和网页音频提示音。会话结束后客服可以关闭，用户切回 AI 接待，并且能给这次服务打一到五分。");
})();

/* ============================================================ S18 功能③ 课程订单闭环 */
(() => {
  const s = newSlide();
  header(s, "18", "03 · 核心实现", "功能③  课程订单闭环：状态机驱动");

  card(s, 0.5, 1.35, 12.33, 2.0);
  s.addText("订单状态机", { x: 0.8, y: 1.52, w: 2, h: 0.3, fontSize: 13.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const states = [["0 待支付", 2.4], ["1 已支付", 5.9], ["2 已核销", 9.4]];
  states.forEach((st, i) => {
    chip(s, st[1], 1.85, 1.8, 0.6, st[0], { fs: 13, bold: true, fill: C.card2, color: i === 2 ? C.green : C.txt });
    if (i < 2) arrowR(s, st[1] + 1.84, 2.15, st[1] + 3.46, C.or, 1.75);
  });
  s.addText("模拟支付（预留微信支付）", { x: 4.05, y: 1.56, w: 3.4, h: 0.26, fontSize: 11.5, color: C.orLt, fontFace: F, margin: 0, align: "center" });
  s.addText("扫码核销 · 记录 verify_at", { x: 7.55, y: 1.56, w: 3.4, h: 0.26, fontSize: 11.5, color: C.orLt, fontFace: F, margin: 0, align: "center" });
  chip(s, 2.4, 2.72, 1.8, 0.5, "3 已取消", { fs: 12, fill: C.card3, color: C.faint });
  arrowD(s, 3.3, 2.47, 2.7, C.faint, 1.25);
  s.addText("用户取消", { x: 3.42, y: 2.44, w: 1.2, h: 0.26, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });

  const impl = [
    ["唯一订单号", "uk_order_no —— 重复创建幂等拒绝"],
    ["金额安全", "DECIMAL(10,2) —— 杜绝浮点误差"],
    ["核销校验", "状态 ≠ 已支付直接拒绝，非法流转进不来"],
    ["全程追溯", "created / paid / verify 时间戳 + 后台一键核销"],
  ];
  impl.forEach((r, i) => {
    const x = 0.5 + (i % 2) * 6.27, y = 3.6 + Math.floor(i / 2) * 1.55;
    card(s, x, y, 6.06, 1.4);
    s.addText(r[0], { x: x + 0.28, y: y + 0.18, w: 5.4, h: 0.32, fontSize: 13.5, bold: true, color: C.orLt, fontFace: F, margin: 0 });
    s.addText(r[1], { x: x + 0.28, y: y + 0.6, w: 5.5, h: 0.6, fontSize: 12, color: C.mut, fontFace: F, margin: 0 });
  });

  s.addText("支付现状：模拟支付接口，状态机与回调挂载点已为微信支付预留（启用前需先上 HTTPS）", {
    x: 0.5, y: 6.75, w: 11.5, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0,
  });

  s.addNotes("第三个功能是交易闭环。核心是左上这个状态机：订单创建后是待支付，模拟支付后变已支付——微信支付的真实回调将来就挂在这一次状态变更上；家长到场出示二维码，客服工作台核销后变已核销，未支付的订单可以取消。四个实现要点：唯一订单号做幂等，金额用 DECIMAL 避免浮点误差，核销接口会校验当前状态必须是已支付、否则直接拒绝，加上三个时间戳让全程可追溯。这样从线上购买到线下核销的闭环就完整了，而且为真实支付留好了挂载点。");
})();

/* ============================================================ S19 功能④ AI 推荐与内容实时同步 */
(() => {
  const s = newSlide();
  header(s, "19", "03 · 核心实现", "功能④  AI 个性化推荐 + 内容实时同步");

  card(s, 0.5, 1.35, 6.06, 5.55);
  s.addText("小宇宙计划 · AI 个性化推荐", { x: 0.82, y: 1.55, w: 5.4, h: 0.34, fontSize: 14, bold: true, color: C.or, fontFace: F, margin: 0 });
  const rec = [
    "家长填写宝宝年龄 + 兴趣方向",
    "候选池检索：课程 4 · 活动 3 · 视频 3",
    "DeepSeek 生成约 100 字推荐导语",
    "结果页聚合展示，一键跳转详情",
  ];
  rec.forEach((t, i) => {
    const yy = 2.15 + i * 0.92;
    card(s, 0.82, yy, 5.4, 0.66, { fill: C.card2, noShadow: true });
    s.addText(String(i + 1) + "   " + t, { x: 1.05, y: yy, w: 5.0, h: 0.66, fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "middle" });
    if (i < 3) arrowD(s, 3.5, yy + 0.68, yy + 0.9, C.or, 1.5);
  });
  s.addShape(pres.shapes.OVAL, { x: 0.84, y: 6.02, w: 0.1, h: 0.1, fill: { color: C.amber } });
  s.addText("大模型不可用 → 模板文案兜底，推荐列表不受影响", { x: 1.05, y: 5.9, w: 5.3, h: 0.35, fontSize: 12, color: C.amber, fontFace: F, margin: 0 });

  card(s, 6.77, 1.35, 6.06, 5.55);
  s.addText("内容实时同步 · 运营免发版", { x: 7.09, y: 1.55, w: 5.4, h: 0.34, fontSize: 14, bold: true, color: C.blueLt, fontFace: F, margin: 0 });
  const sync = [
    "后台保存：课程 / banner / 活动 …",
    "CrudController 自动推高频道版本号",
    "SSE /api/sync/stream 推送（H5 EventSource）",
    "非 H5 端 5s 轮询版本号兜底",
    "家长端自动刷新，新内容即时可见",
  ];
  sync.forEach((t, i) => {
    const yy = 2.15 + i * 0.86;
    card(s, 7.09, yy, 5.4, 0.62, { fill: C.card2, noShadow: true });
    s.addText(String(i + 1) + "   " + t, { x: 7.32, y: yy, w: 5.0, h: 0.62, fontSize: 12, color: C.txt, fontFace: F, margin: 0, valign: "middle" });
    if (i < 4) arrowD(s, 9.75, yy + 0.64, yy + 0.84, C.blue, 1.5);
  });
  s.addShape(pres.shapes.OVAL, { x: 7.11, y: 6.28, w: 0.1, h: 0.1, fill: { color: C.faint } });
  s.addText("DataVersionService 纯 JUC 实现（AtomicLong + 队列），不依赖 WebFlux", { x: 7.32, y: 6.16, w: 5.3, h: 0.35, fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  s.addNotes("第四个功能和它背后的同步机制。小宇宙计划是产品的特色入口：家长填宝宝年龄和兴趣，系统从真实业务数据里检索候选——四门课、三个活动、三个视频——再让大模型写一段约一百字的推荐导语；大模型不可用就用模板兜底，推荐永远能出结果。右边这套实时同步机制是运营侧的命脉：后台每次保存数据，通用基类自动推高对应频道的版本号，H5 端通过 SSE 收到推送，小程序和 App 用五秒轮询版本号兜底，家长端自动刷新。这意味着运营改任何内容都不需要发版。");
})();

/* ============================================================ S20 前端实现① 三端同构 */
(() => {
  const s = newSlide();
  header(s, "20", "03 · 核心实现", "前端实现①  三端同构：一套契约，三份实现");

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

  s.addNotes("前端最有价值的不是某个页面，而是「同构复用」。三端遵循完全一致的契约：统一响应信封、统一 token 注入、统一 401 处理、同一套 WebSocket 协议——所以 Flutter 端和 uniapp 端的 IM 服务是逐行对应的两个实现，谁也不会悄悄漂移。Flutter 端二十七个页面，网络层是手写的统一封装；uniapp 端二十六个页面，IM 单例带 ACK 重发和自动重连；管理后台十四个视图，其中十二个列表页由一个通用组件生成。下一页展开这两套复用抽象。");
})();

/* ============================================================ S21 前端实现② 跨端复用工程 */
(() => {
  const s = newSlide();
  header(s, "21", "03 · 核心实现", "前端实现②  「配置驱动」的成对抽象");

  card(s, 0.5, 1.35, 5.35, 2.05);
  s.addText([
    { text: "CrudController（后端通用基类）", options: { bold: true, color: C.orLt, fontSize: 13.5, breakLine: true } },
    { text: "12 个模块继承 → 每模块自动获得", options: { color: C.txt, fontSize: 12, breakLine: true } },
    { text: "列表 / 新增 / 详情 / 删除 4 个接口", options: { color: C.txt, fontSize: 12, breakLine: true } },
    { text: "数据变更自动推高频道版本号", options: { color: C.mut, fontSize: 12 } },
  ], { x: 0.8, y: 1.58, w: 4.8, h: 1.6, fontFace: F, margin: 0, paraSpaceAfter: 5 });

  card(s, 7.48, 1.35, 5.35, 2.05);
  s.addText([
    { text: "ListPage.vue（前端通用组件 · 483 行）", options: { bold: true, color: C.blueLt, fontSize: 13.5, breakLine: true } },
    { text: "columns / formFields / api 三个配置", options: { color: C.txt, fontSize: 12, breakLine: true } },
    { text: "→ 生成完整增删改查页（分页 / 搜索 / 上传）", options: { color: C.txt, fontSize: 12, breakLine: true } },
    { text: "12 个后台列表页零重复代码", options: { color: C.mut, fontSize: 12 } },
  ], { x: 7.78, y: 1.58, w: 4.8, h: 1.6, fontFace: F, margin: 0, paraSpaceAfter: 5 });

  chip(s, 6.08, 2.08, 1.17, 0.6, "配置驱动", { fs: 12.5, bold: true, fill: C.card2, color: C.or });
  arrowR(s, 5.88, 2.38, 6.06, C.or, 1.5);
  arrowR(s, 7.27, 2.38, 7.45, C.or, 1.5);

  card(s, 0.5, 3.65, 12.33, 1.0, { fill: C.card3, noShadow: true });
  s.addText([
    { text: "对称的价值   ", options: { bold: true, color: C.or } },
    { text: "后端加一个管理模块 ≈ 声明实体 + 继承基类；前端加一个列表页 ≈ 传三个配置。新增模块的前后端工作量都收敛到「填配置」，一共 12 个模块 × 12 个页面由此而来。", options: { color: C.txt } },
  ], { x: 0.82, y: 3.65, w: 11.7, h: 1.0, fontSize: 12.5, fontFace: F, margin: 0, valign: "middle" });

  s.addText("典型页面生命周期 —— AI 客服页（uniapp 与 Flutter 逐行对应）", { x: 0.5, y: 4.85, w: 9, h: 0.3, fontSize: 13, bold: true, color: C.or, fontFace: F, margin: 0 });
  const life = ["onShow 触发", "initSession 建会话", "WS 连接 + 心跳", "发送 → ACK 确认", "渲染 · 失败重试", "needTransfer 转人工"];
  life.forEach((t, i) => {
    const x = 0.5 + i * 2.08;
    chip(s, x, 5.28, 1.92, 0.8, t, { fs: 11.5, fill: C.card2 });
    if (i < 5) arrowR(s, x + 1.94, 5.68, x + 2.06, C.or, 1.5);
  });
  s.addText("契约先行：先定协议与目录规范，再写两端实现 —— 这是「双框架」策略成立的前提", {
    x: 0.5, y: 6.35, w: 11, h: 0.3, fontSize: 12, color: C.faint, fontFace: F, margin: 0,
  });

  s.addNotes("这一页解释双框架策略为什么成立：因为后端和前端各有一个「配置驱动」的抽象，而且它们是对称的。后端的 CrudController 基类让十二个管理模块只声明实体就自动拥有四个接口，还会推数据版本号；前端的 ListPage 组件让十二个列表页只传三个配置就完整生成。所以新增一个管理模块，前后端的工作量都收敛到填配置。下面这条生命周期是 AI 客服页从进入到转人工的完整过程，这段逻辑在 uniapp 和 Flutter 两端是逐行对应的——契约先行，才敢用两个框架。");
})();

/* ============================================================ S22 后端实现① 分层与统一协议 */
(() => {
  const s = newSlide();
  header(s, "22", "03 · 核心实现", "后端实现①  通用基类 + 统一协议，压住 108 个接口");

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

  s.addNotes("后端是标准三层，二十个 Controller 对应二十个 Service、十七个 Mapper。控制复杂度靠两个设计：一是 CrudController 基类，十二个管理模块的增删改查全部下沉，子类声明实体就自动拥有接口；二是统一协议——所有接口返回同一个信封，所有异常被全局处理器兜住，认证集中在拦截器加三十条白名单。右侧是 AI 客服接口的完整五步链路，从意图识别、FAQ、大模型到降级，每层职责和出口都明确；下面还有订单核销案例，演示状态机校验如何防止非法流转。");
})();

/* ============================================================ S23 后端实现② 代表 API 案例 */
(() => {
  const s = newSlide();
  header(s, "23", "03 · 核心实现", "后端实现②  两个 API 案例拆到底");

  card(s, 0.5, 1.35, 12.33, 2.95);
  s.addText([
    { text: "案例 1 ｜ ", options: { bold: true, color: C.or } },
    { text: "POST /api/ai/service-chat —— AI 客服全链路", options: { bold: true, color: C.txt } },
  ], { x: 0.8, y: 1.53, w: 8, h: 0.32, fontSize: 13.5, fontFace: F, margin: 0 });
  const steps1 = [["1", "建 / 取会话\n保存用户消息"], ["2", "转人工\n意图识别"], ["3", "FAQ 知识库\n检索"], ["4", "DeepSeek\n多轮生成"], ["5", "降级兜底\n回复落库"]];
  steps1.forEach((st, i) => {
    const x = 0.8 + i * 2.42;
    chip(s, x, 2.0, 2.15, 0.95, "", { fill: C.card2 });
    s.addText([
      { text: st[0] + "  ", options: { bold: true, color: C.or, fontSize: 14 } },
      { text: st[1], options: { color: C.txt, fontSize: 11.5 } },
    ], { x, y: 2.0, w: 2.15, h: 0.95, align: "center", valign: "middle", fontFace: F, margin: 0 });
    if (i < 4) arrowR(s, x + 2.17, 2.47, x + 2.4, C.or, 1.5);
  });
  const branch = [["命中 → needTransfer 立即返回", 1], ["命中 → 直接返回 · hit_count +1", 2], ["异常 → 固定话术 + 引导转人工", 4]];
  branch.forEach((b) => {
    const cx = 0.8 + b[1] * 2.42 + 2.15 / 2;
    s.addText(b[0], { x: cx - 1.15, y: 3.1, w: 2.3, h: 0.6, fontSize: 11.5, color: C.amber, fontFace: F, margin: 0, align: "center" });
  });

  card(s, 0.5, 4.5, 12.33, 2.4);
  s.addText([
    { text: "案例 2 ｜ ", options: { bold: true, color: C.or } },
    { text: "POST /api/order/{id}/verify —— 订单核销的状态机校验", options: { bold: true, color: C.txt } },
  ], { x: 0.8, y: 4.68, w: 8, h: 0.32, fontSize: 13.5, fontFace: F, margin: 0 });
  s.addText("核销前先校验订单状态机：非法状态直接拒绝，杜绝「未支付先核销」；核销成功记录 verify_at，全程可追溯。", {
    x: 0.8, y: 5.1, w: 4.6, h: 1.4, fontSize: 12, color: C.mut, fontFace: F, margin: 0, valign: "top",
  });
  card(s, 5.6, 4.95, 6.95, 1.75, { fill: "0A0F1C", noShadow: true });
  s.addText([
    { text: "Order o = orderMapper.selectById(id);", options: { breakLine: true } },
    { text: "if (o.getStatus() != 1)", options: { color: C.red, breakLine: true } },
    { text: "    return R.fail(\"当前状态不可核销\");", options: { breakLine: true } },
    { text: "o.setStatus(2);  o.setVerifyAt(now);", options: { breakLine: true } },
    { text: "orderMapper.updateById(o);", options: { color: C.green } },
  ], { x: 5.85, y: 5.1, w: 6.5, h: 1.5, fontSize: 11.5, color: C.txt, fontFace: FC, margin: 0, paraSpaceAfter: 3 });

  s.addNotes("把两个案例拆到底。上面是 AI 客服接口的五步链路，注意琥珀色的三个分支：第二步命中转人工意图就立即短路返回；第三步命中 FAQ 也直接返回，顺便给这条知识的热度加一；第五步任何异常都降级成固定话术。下面是订单核销的真实校验代码：状态不是已支付就直接拒绝，只有合法流转才能置为已核销并记录时间。这两段合起来说明一件事——接口层的可靠性来自「每一步都有明确出口」这个纪律，而不是靠运气。");
})();

/* ============================================================ S24 分节 04 */
(() => {
  const s = newSlide();
  divider(s, 4, "攻坚与加固", "遇到什么问题，怎么解决？", [
    "难点①  AI 服务的质量 · 成本 · 可用性矛盾",
    "难点②  弱网下 WebSocket 消息的丢失与重复",
    "难点③  AI → 人工的无缝转接",
    "难点④  CI/CD 部署清空线上库（真实事故复盘）",
    "安全六层防护与性能机制优化",
  ]);
  pageNum(s, "24");
  s.addNotes("第四部分是全场最能体现工程能力的：四个真实踩过的坑逐个复盘，每个都按问题、原因、方案、原理、效果五段展开，其中第四个是真实发生过的线上事故。之后是安全设计的六层防护和性能优化，我会如实标注哪些做了、哪些还没做。");
})();

/* ============================================================ S25 难点① AI 可用性 */
(() => {
  const s = newSlide();
  header(s, "25", "04 · 攻坚与加固", "难点①  AI 服务的质量 · 成本 · 可用性矛盾");

  card(s, 0.5, 1.35, 7.45, 5.55);
  const rows = [
    ["问题", "大模型直接当客服 —— 慢、贵、不稳定", C.red, 0.4],
    ["原因", "响应秒级 · token 成本随对话增长 · 网络偶发超时", C.mut, 0.4],
    ["方案", "三级漏斗：意图识别 → FAQ 知识库优先 → DeepSeek 兜底；60s 超时熔断", C.blueLt, 0.7],
    ["原理", "检索增强（RAG 思想的最小实现）+ 超时熔断 + 降级兜底", C.orLt, 0.7],
    ["效果", "高频问题毫秒级返回（单次 DB 查询）· 业务口径可控 · 主流程永不报错", C.green, 0.7],
  ];
  rows.forEach((r, i) => {
    const yy = 1.75 + i * 0.98;
    s.addText(r[0], { x: 0.82, y: yy + 0.02, w: 0.62, h: 0.3, fontSize: 12.5, bold: true, color: r[2], fontFace: F, margin: 0 });
    s.addText(r[1], { x: 1.52, y: yy, w: 6.1, h: r[3], fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "top" });
    if (i < 4) s.addShape(pres.shapes.LINE, { x: 0.82, y: yy + 0.82, w: 6.8, h: 0, line: { color: C.stroke, width: 0.75 } });
  });

  card(s, 8.15, 1.35, 4.68, 5.55);
  s.addText("漏斗速览", { x: 8.45, y: 1.55, w: 3, h: 0.3, fontSize: 13, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const fs_ = [["意图识别", "命中 → 转人工"], ["FAQ 检索", "命中 → 毫秒级返回"], ["DeepSeek", "长尾 → 生成回答"]];
  fs_.forEach((f, i) => {
    const yy = 2.0 + i * 1.14;
    card(s, 8.7, yy, 3.55, 0.72, { fill: C.card2, noShadow: true });
    s.addText([
      { text: f[0] + "  ", options: { bold: true, color: C.orLt } },
      { text: f[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 8.7, y: yy, w: 3.55, h: 0.72, align: "center", valign: "middle", fontSize: 12.5, fontFace: F, margin: 0 });
    if (i < 2) arrowD(s, 10.45, yy + 0.74, yy + 1.12, C.faint, 1.5);
  });
  card(s, 8.7, 5.5, 3.55, 0.75, { dash: "dash", line: C.strokeDash, fill: C.card3, noShadow: true });
  s.addText("任意异常 → 降级文案兜底", { x: 8.7, y: 5.5, w: 3.55, h: 0.75, align: "center", valign: "middle", fontSize: 12, color: C.amber, fontFace: F, margin: 0 });

  s.addNotes("难点一。问题很直接：大模型又慢又贵还不稳定，直接当客服不可用。原因是响应在秒级、token 成本随对话轮数线性增长、网络还偶发超时。我的方案是三级漏斗——意图识别、FAQ 知识库优先、DeepSeek 兜底，外加六十秒超时熔断。原理上这是检索增强思想的最小实现：能检索到的绝不生成，同时用熔断和降级保证可用性。效果是高频业务问题变成一次数据库查询，毫秒级返回，而且答案口径由运营维护、完全可控，主流程永远不会报错。这些是定性结论，我没有编造量化指标。");
})();

/* ============================================================ S26 难点② WS 消息可靠性 */
(() => {
  const s = newSlide();
  header(s, "26", "04 · 攻坚与加固", "难点②  弱网下 WebSocket 消息的丢失与重复");

  card(s, 0.5, 1.35, 7.45, 5.55);
  const rows = [
    ["问题", "弱网 / 锁屏断连，重连后重发 —— 消息会丢、会重", C.red, 0.7],
    ["原因", "TCP 断开无应用层通知；客户端重试没有幂等保障", C.mut, 0.7],
    ["方案", "ACK 确认 + clientMsgId 幂等 + 4s 自动重连 + 重连拉历史补偿", C.blueLt, 0.7],
    ["原理", "应用层确认协议 + 数据库唯一键兜底 + 服务端批量标已读", C.orLt, 0.7],
    ["效果", "消息不丢、不重、会话状态可恢复 —— 三端协议完全一致", C.green, 0.4],
  ];
  rows.forEach((r, i) => {
    const yy = 1.75 + i * 0.98;
    s.addText(r[0], { x: 0.82, y: yy + 0.02, w: 0.62, h: 0.3, fontSize: 12.5, bold: true, color: r[2], fontFace: F, margin: 0 });
    s.addText(r[1], { x: 1.52, y: yy, w: 6.1, h: r[3], fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "top" });
    if (i < 4) s.addShape(pres.shapes.LINE, { x: 0.82, y: yy + 0.82, w: 6.8, h: 0, line: { color: C.stroke, width: 0.75 } });
  });

  card(s, 8.15, 1.35, 4.68, 5.55);
  s.addText("消息确认时序", { x: 8.45, y: 1.55, w: 3, h: 0.3, fontSize: 13, bold: true, color: C.txt, fontFace: F, margin: 0 });
  const seq = [
    ["发送方", "生成 clientMsgId · 进待确认队列"],
    ["服务端", "唯一键查重 → 落库 → 回 ACK"],
    ["发送方", "收到 ACK → 标记成功 · 渲染"],
  ];
  seq.forEach((c, i) => {
    const yy = 2.0 + i * 1.14;
    card(s, 8.7, yy, 3.55, 0.72, { fill: C.card2, noShadow: true });
    s.addText([
      { text: c[0] + "  ", options: { bold: true, color: C.orLt, breakLine: true } },
      { text: c[1], options: { color: C.mut, fontSize: 11.5 } },
    ], { x: 8.7, y: yy, w: 3.55, h: 0.72, align: "center", valign: "middle", fontSize: 12, fontFace: F, margin: 0 });
    if (i < 2) arrowD(s, 10.45, yy + 0.74, yy + 1.12, C.or, 1.5);
  });
  card(s, 8.7, 5.42, 3.55, 1.05, { dash: "dash", line: C.strokeDash, fill: C.card3, noShadow: true });
  s.addText([
    { text: "6s 无 ACK → 标记失败可重试", options: { color: C.amber, breakLine: true } },
    { text: "断线 4s 重连 → 拉历史 + 批量已读", options: { color: C.blueLt } },
  ], { x: 8.7, y: 5.42, w: 3.55, h: 1.05, align: "center", valign: "middle", fontSize: 12, fontFace: F, margin: 0, paraSpaceAfter: 5 });

  s.addNotes("难点二是移动端绕不开的弱网问题。手机切网、锁屏都会断连接，重连后重发消息就会重复，不重发又会丢。我的方案是一套应用层确认协议：每条消息带客户端生成的消息号，先进入待确认队列，服务端落库前按数据库唯一键查重，落库成功才回 ACK；六秒没收到 ACK 就标记失败、允许手动重发——重发也不怕，唯一键挡着。断线四秒自动重连，重连成功后拉一次历史把缺口补齐，服务端顺带批量标已读。这套协议在 uniapp 和 Flutter 两端是一致的实现。");
})();

/* ============================================================ S27 难点③ AI→人工转接 */
(() => {
  const s = newSlide();
  header(s, "27", "04 · 攻坚与加固", "难点③  AI → 人工的无缝转接");

  card(s, 0.5, 1.35, 7.45, 5.55);
  const rows = [
    ["问题", "AI 会话转人工 —— 上下文、归属、通知都要迁移", C.red, 0.4],
    ["原因", "转接前会话无客服归属（cs_id 空 · type=1），且客服可能不在线", C.mut, 0.7],
    ["方案", "三级调度选定客服 → 会话状态机切换 → 系统消息 + WS 双端推送", C.blueLt, 0.7],
    ["原理", "同一会话续聊不换 sessionId；调度按在线状态优先级排序", C.orLt, 0.7],
    ["效果", "用户无感切换 · 客服响铃接入 · 结束可评分 / 切回 AI", C.green, 0.4],
  ];
  rows.forEach((r, i) => {
    const yy = 1.75 + i * 0.98;
    s.addText(r[0], { x: 0.82, y: yy + 0.02, w: 0.62, h: 0.3, fontSize: 12.5, bold: true, color: r[2], fontFace: F, margin: 0 });
    s.addText(r[1], { x: 1.52, y: yy, w: 6.1, h: r[3], fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "top" });
    if (i < 4) s.addShape(pres.shapes.LINE, { x: 0.82, y: yy + 0.82, w: 6.8, h: 0, line: { color: C.stroke, width: 0.75 } });
  });

  card(s, 8.15, 1.35, 4.68, 5.55);
  s.addText("三级客服调度", { x: 8.45, y: 1.55, w: 3, h: 0.3, fontSize: 13, bold: true, color: C.txt, fontFace: F, margin: 0 });
  chip(s, 8.7, 1.98, 3.55, 0.55, "转人工请求（按钮 / 关键词）", { fs: 12, fill: C.card2, color: C.orLt, bold: true });
  const lv = [["①", "本店 + 真实在线（WS 已连）"], ["②", "本店任一客服"], ["③", "全平台兜底"]];
  lv.forEach((l, i) => {
    const yy = 2.75 + i * 0.92;
    card(s, 8.7, yy, 3.55, 0.68, { fill: C.card2, noShadow: true });
    s.addText([
      { text: l[0] + " ", options: { bold: true, color: C.or } },
      { text: l[1], options: { color: C.txt } },
    ], { x: 8.95, y: yy, w: 3.2, h: 0.68, fontSize: 12, fontFace: F, margin: 0, valign: "middle" });
  });
  s.addText("排序：online DESC, id ASC —— 优先真人在线", { x: 8.72, y: 5.52, w: 3.6, h: 0.28, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });
  const acts = ["type 1 → 2", "写 cs_id", "transfer_notice", "WS 通知双方"];
  acts.forEach((t, i) => {
    const col = i % 2, row = Math.floor(i / 2);
    chip(s, 8.7 + col * 1.83, 5.88 + row * 0.52, 1.72, 0.44, t, { fs: 11, fill: C.card3, color: C.blueLt });
  });

  s.addNotes("难点三是转人工。转接前会话是没有客服归属的，cs_id 为空、类型是 AI，而且目标客服可能根本不在线。我的方案分三步：先用三级调度选人——优先本店且真实在线的客服，其次本店任何客服，最后全平台兜底，排序按在线状态优先；选中后把会话类型从一切到二、写入客服 ID；再插入一条系统消息并通过 WebSocket 同时通知用户端和客服工作台。关键原理是自始至终同一个会话 ID，用户之前跟 AI 说的话客服全都能看到，体验上是无缝的。结束之后可以切回 AI，也可以评分。");
})();

/* ============================================================ S28 难点④ 清库事故复盘 */
(() => {
  const s = newSlide();
  header(s, "28", "04 · 攻坚与加固", "难点④  CI/CD 部署清空线上库 —— 真实事故复盘");

  card(s, 0.5, 1.35, 7.45, 5.55);
  const rows = [
    ["现象", "schema.sql 含 DROP TABLE IF EXISTS，部署直接导入即重建全表", C.red, 0.7],
    ["影响", "每次自动部署都可能清空线上生产数据 —— 真实发生过", C.amber, 0.4],
    ["修复", "init-db.sh 幂等化：检测已有表 → 转换安全版 → 只补缺失表 / 列", C.blueLt, 0.7],
    ["防线", "表数量 + 14 张核心表校验 · 60s 健康检查 · 10 份备份回滚", C.orLt, 0.7],
    ["结果", "修复后自动部署零数据事故，具备分钟级回滚能力（commit 778ee39）", C.green, 0.7],
  ];
  rows.forEach((r, i) => {
    const yy = 1.75 + i * 0.98;
    s.addText(r[0], { x: 0.82, y: yy + 0.02, w: 0.62, h: 0.3, fontSize: 12.5, bold: true, color: r[2], fontFace: F, margin: 0 });
    s.addText(r[1], { x: 1.52, y: yy, w: 6.1, h: r[3], fontSize: 12.5, color: C.txt, fontFace: F, margin: 0, valign: "top" });
    if (i < 4) s.addShape(pres.shapes.LINE, { x: 0.82, y: yy + 0.82, w: 6.8, h: 0, line: { color: C.stroke, width: 0.75 } });
  });

  card(s, 8.15, 1.35, 4.68, 3.4);
  s.addText("部署脚本自动转换", { x: 8.45, y: 1.52, w: 3, h: 0.3, fontSize: 12.5, bold: true, color: C.txt, fontFace: F, margin: 0 });
  card(s, 8.4, 1.92, 4.18, 2.6, { fill: "0A0F1C", noShadow: true });
  s.addText([
    { text: "-- 检测到库中已有数据时：", options: { color: C.faint, breakLine: true } },
    { text: "DROP TABLE IF EXISTS `order`", options: { color: C.red, breakLine: true } },
    { text: "  → 整行剔除", options: { color: C.amber, breakLine: true } },
    { text: "CREATE TABLE `order` (...)", options: { color: C.red, breakLine: true } },
    { text: "  → CREATE TABLE IF NOT EXISTS", options: { color: C.green, breakLine: true } },
    { text: "-- 再执行幂等迁移脚本补列", options: { color: C.faint } },
  ], { x: 8.62, y: 2.08, w: 3.8, h: 2.3, fontSize: 11, color: C.txt, fontFace: FC, margin: 0, paraSpaceAfter: 3 });

  card(s, 8.15, 4.95, 4.68, 1.95);
  s.addText("三道防线", { x: 8.45, y: 5.12, w: 3, h: 0.3, fontSize: 12.5, bold: true, color: C.or, fontFace: F, margin: 0 });
  const def = ["健康检查 60s", "核心表校验", "备份 10 份"];
  def.forEach((t, i) => chip(s, 8.45 + i * 1.42, 5.55, 1.32, 0.5, t, { fs: 11, fill: C.card2 }));
  s.addText("任何一道不过 → 部署判定失败", { x: 8.45, y: 6.25, w: 4.1, h: 0.3, fontSize: 11.5, color: C.faint, fontFace: F, margin: 0 });

  s.addNotes("难点四是一次真实事故。我们的 schema 文件里带 DROP TABLE，早期部署直接导入，等于每次发版都可能把线上库清空，这真实发生过。修复分两层：脚本层，把初始化改成幂等的——检测到库里已有数据，就自动把 schema 转换成安全版本，DROP 整行剔除、CREATE 改成 IF NOT EXISTS，只补建缺失的表和列；校验层，部署后用 information_schema 核对表数量和十四张核心表是否齐全，再做六十秒健康检查，加上十份历史备份随时回滚。修复提交之后到现在，自动部署零数据事故。这个案例给我的教训是：自动化流程里的每一个假设，都必须有校验兜底。");
})();

/* ============================================================ S29 安全设计 */
(() => {
  const s = newSlide();
  header(s, "29", "04 · 攻坚与加固", "安全设计：从认证到上传的六层防护");

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
  s.addText("不回避短板 —— 均已列入 P34 升级路线", { x: 8.55, y: 5.9, w: 4.0, h: 0.6, fontSize: 12, color: C.faint, fontFace: F, margin: 0 });

  s.addNotes("安全面我做了六层：JWT 认证且密钥走环境变量；BCrypt 存密码并防止重复加密；拦截器加方法级白名单控制公开接口范围；SQL 全部预编译；上传有类型白名单和 UUID 重命名；所有第三方密钥只从环境变量注入，仓库里没有任何明文。同时如实说三个还没做的：HTTPS、token 刷新、按钮级 RBAC——我把它们列为下一阶段的明确事项，而不是回避。");
})();

/* ============================================================ S30 性能优化 */
(() => {
  const s = newSlide();
  header(s, "30", "04 · 攻坚与加固", "性能优化：优化做在机制上，不编造数字");

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

/* ============================================================ S31 分节 05 */
(() => {
  const s = newSlide();
  divider(s, 5, "上线与收获", "最终效果如何？", [
    "部署与工程化：提交即上线，幂等部署 + 双重校验 + 可回滚",
    "项目成果：全部可在代码中核实的真实数字",
    "总结与未来规划：每条规划对应一个真实短板",
  ]);
  pageNum(s, "31");
  s.addNotes("最后一部分回答效果如何：先看全自动部署流水线，再看一组可以在代码里逐一核实的成果数字，最后是总结和每条都对应真实短板的未来规划。");
})();

/* ============================================================ S32 部署与工程化 */
(() => {
  const s = newSlide();
  header(s, "32", "05 · 上线与收获", "部署与工程化：提交即上线 · 幂等部署 · 可回滚");

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

  s.addNotes("部署是这个项目工程化程度最高的部分。推一次代码，GitHub Actions 会并行构建四个产物：后端 jar、后台前端、安卓安装包和 Flutter Web，然后自动上传服务器——上传前先备份旧版本，保留十份随时回滚。数据库初始化是幂等的，绝不覆盖线上数据，这就是前面清库事故换来的防线；重启后有两道验收：接口健康检查加数据库表结构校验，任何一道不过就判失败。运行期由 systemd 守护，进程挂了五秒内自动拉起。整套流程十几分钟，无人值守。");
})();

/* ============================================================ S33 项目成果 */
(() => {
  const s = newSlide();
  header(s, "33", "05 · 上线与收获", "项目成果：全部可核实的真实数字");

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

/* ============================================================ S34 总结与未来规划 */
(() => {
  const s = newSlide();
  header(s, "34", "05 · 上线与收获", "总结与未来规划：完成度已闭环，规划对着短板来");

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

pres.writeFile({ fileName: "优童成长社-项目答辩PPT.pptx" }).then(() => console.log("DONE"));
