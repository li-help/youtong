// 全局配置
export const BASE_URL = 'http://localhost:3001/api'

// 占位图（本地纯色块，避免使用外部图片素材）
export const PLACEHOLDER = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(
  `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="#FFE0B2"/><text x="50%" y="50%" font-size="20" fill="#FFA000" text-anchor="middle" dominant-baseline="middle">优童</text></svg>`
)

// 根据资源返回占位封面
export function coverOf(item) {
  return item && (item.cover || item.image || item.logo) ? item.cover || item.image || item.logo : PLACEHOLDER
}
