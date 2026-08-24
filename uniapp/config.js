// 全局配置
// ============================================================
// 后端 API 地址。默认指向已上线生产环境（Nginx 反代 /api）。
//   - 生产环境（已上线）：http://123.56.160.50/api
//   - 本地开发可覆盖：    http://localhost:3001/api
// 优先级：构建环境变量 UNI_APP_API_URL > 下方默认值
//   命令行打包示例:
//     H5:   UNI_APP_API_URL=https://你的域名/api npm run build:h5
//     App:  UNI_APP_API_URL=https://你的域名/api npm run build:app
// 注：微信小程序 / 微信支付要求 HTTPS，正式对外请将默认值替换为 https 域名。
// ============================================================
const ENV_API_URL = typeof process !== 'undefined' && process.env && process.env.UNI_APP_API_URL
export const BASE_URL = ENV_API_URL || 'http://123.56.160.50/api'

// 占位图（本地纯色块，避免使用外部图片素材）
export const PLACEHOLDER = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(
  `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="#FFE0B2"/><text x="50%" y="50%" font-size="20" fill="#FFA000" text-anchor="middle" dominant-baseline="middle">优童</text></svg>`
)

// 图片服务器地址：后端 /uploads/** 由 WebMvcConfig 提供静态资源，管理端存储的是相对路径
// #ifdef H5
// H5 端使用相对路径 /uploads/...，由 Nginx 反代到后端，避免硬编码 localhost 导致图片加载失败
const IMG_BASE = ''
// #endif
// #ifndef H5
// 小程序 / App 端：拼接完整后端地址
const IMG_BASE = BASE_URL.replace(/\/api$/, '')
// #endif

// 把后端相对路径（如 /uploads/xxx.png）解析为可访问的绝对地址；http(s)/data 等绝对地址原样返回
export function resolveImg(url) {
  if (!url || typeof url !== 'string') return url
  if (/^(https?:|data:|\/\/)/i.test(url)) return url
  if (url.startsWith('/')) return IMG_BASE + url
  return url
}

// 根据资源返回可展示封面（相对路径自动补全后端地址，避免 App 端加载不到管理端上传的图片）
export function coverOf(item) {
  const src = item && (item.cover || item.image || item.logo) ? item.cover || item.image || item.logo : PLACEHOLDER
  return resolveImg(src)
}
