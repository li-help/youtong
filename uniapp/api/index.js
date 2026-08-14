import request from './request.js'

// 统一封装各业务模块的 API，路径与后端 youtong-admin-backend 接口契约一致。
// 约定：后端返回结构为 { code, msg, data }，data 中列表接口为分页对象 {list,total,...}

function parsePage(res) {
  // request 已解析为 R.data，即后端 R.page 返回的分页对象 {list,total,...}
  const d = res || {}
  if (Array.isArray(d.list)) return d
  if (Array.isArray(d.records)) return { list: d.records, total: d.total || d.records.length }
  if (Array.isArray(d)) return { list: d, total: d.length }
  return { list: [], total: 0 }
}

// 认证
export const authApi = {
  login: (username, password) => request.post('/auth/login', { username, password }),
  register: (username, password, nickname) => request.post('/auth/register', { username, password, nickname }),
  logout: () => request.post('/auth/logout', {}),
  info: () => request.post('/auth/info', {})
}

// 用户（需登录）
export const userApi = {
  me: () => request.get('/user/me', {}),
  updateProfile: (data) => request.post('/user/profile', data)
}

// 课程（C 端公开列表 / 推荐；详情需登录）
export const courseApi = {
  list: (params) => request.get('/course/list', params).then(parsePage),
  recommend: (size = 5) => request.get('/course/recommend', { size }).then(r => (r && Array.isArray(r.list) ? r.list : (r && Array.isArray(r) ? r : []))),
  detail: (id) => request.get('/course/' + id, {})
}

// 门店（公开列表 / 详情需登录）
export const storeApi = {
  list: (params) => request.get('/store/list', params).then(parsePage),
  detail: (id) => request.get('/store/' + id, {})
}

// 服务（公开列表）
export const serviceApi = {
  list: (params) => request.get('/service/list', params).then(parsePage),
  detail: (id) => request.get('/service/' + id, {})
}

// 活动（公开列表 / 详情需登录）
export const activityApi = {
  list: (params) => request.get('/activity', params).then(parsePage),
  detail: (id) => request.get('/activity/' + id, {})
}

// 视频（公开列表 / 详情需登录）
export const videoApi = {
  list: (params) => request.get('/video', params).then(parsePage),
  detail: (id) => request.get('/video/' + id, {})
}

// 资讯文章（公开列表 / 详情）
export const articleApi = {
  list: (params) => request.get('/article/published', params).then(parsePage),
  detail: (id) => request.get('/article/view/' + id, {})
}

// 分类（公开）
export const categoryApi = {
  list: (params) => request.get('/category', params).then(parsePage)
}

// 轮播/banner（公开）
export const bannerApi = {
  home: (code = 'home_banner') => request.get('/banner/' + code, {}).then(r => (r && Array.isArray(r.list) ? r.list : (r && Array.isArray(r) ? r : [])))
}

// 订单（需登录）
export const orderApi = {
  list: (params) => request.get('/order', params).then(parsePage),
  create: (data) => request.post('/order/create', data),
  verify: (id) => request.post('/order/verify', { id })
}

export default {
  authApi, userApi, courseApi, storeApi, serviceApi,
  activityApi, videoApi, articleApi, categoryApi, bannerApi, orderApi
}
