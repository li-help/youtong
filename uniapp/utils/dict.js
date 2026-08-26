// 统一字典/枚举映射，全站复用，避免各页面零散硬编码中文文案。
// 后端返回的多为英文枚举，前端统一在此转中文。

// 活动状态
export const ACTIVITY_STATUS = {
  ongoing: '进行中',
  upcoming: '即将开始',
  finished: '已结束',
  draft: '草稿'
}
export function activityStatusText(s) {
  return ACTIVITY_STATUS[s] || (s ? String(s) : '')
}

// 订单状态
export const ORDER_STATUS = {
  pending: '待支付',
  paid: '已支付',
  completed: '已完成',
  cancelled: '已取消',
  refunded: '已退款'
}
export function orderStatusText(s) {
  return ORDER_STATUS[s] || (s ? String(s) : '')
}

// 课程 ageRange 等可按需扩展
