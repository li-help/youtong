import { imApi } from '../api/index.js'

/**
 * 刷新底部 tab「智能」上的客服未读角标
 * 数据来源：当前用户会话列表的 unreadCountUser 汇总
 */
export async function refreshUnreadBadge() {
  const token = uni.getStorageSync('token')
  if (!token) return
  try {
    const sessions = await imApi.sessionList()
    const list = Array.isArray(sessions) ? sessions : []
    const unread = list.reduce((sum, s) => sum + (Number(s.unreadCountUser) || 0), 0)
    if (unread > 0) {
      uni.setTabBarBadge({ index: 1, text: String(Math.min(unread, 99)), fail: () => {} })
    } else {
      uni.removeTabBarBadge({ index: 1, fail: () => {} })
    }
  } catch (e) {}
}
