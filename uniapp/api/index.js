import request, { BASE_URL } from './request.js'

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
  wechatLogin: (code) => request.post('/auth/wechatLogin', { code }),
  scanCreate: () => request.post('/auth/scanLogin/create', {}),
  scanCheck: (ticket) => request.post('/auth/scanLogin/check', { ticket }),
  scanMarked: (ticket) => request.post('/auth/scanLogin/marked', { ticket }),
  // 手机端确认：小程序扫码页 uni.login 拿到 code 后调用
  scanConfirm: (ticket, code) => request.post('/auth/scanLogin/confirm', { ticket, code }),
  register: (username, password, nickname, code) => request.post('/auth/register', { username, password, nickname, code }),
  logout: () => request.post('/auth/logout', {}),
  resetPwd: (username, oldPassword, newPassword) => request.post('/auth/resetPwd', { username, oldPassword, newPassword }),
  resetPwdByCode: (phone, code, newPassword) => request.post('/auth/resetPwdByCode', { phone, code, newPassword }),
  sendCode: (phone) => request.post('/auth/sendCode', { phone }),
  checkCode: (phone, code) => request.post('/auth/checkCode', { phone, code }),
  // 手机号 + 验证码登录（免密，未注册自动注册）
  phoneLogin: (phone, code) => request.post('/auth/phoneLogin', { phone, code }),
  info: () => request.post('/auth/info', {})
}

// 用户（需登录）
export const userApi = {
  me: () => request.get('/user/me', {}),
  updateProfile: (data) => request.post('/user/profile', data),
  stats: () => request.get('/user/stats', {})
}

// 收货地址（需登录）
export const addressApi = {
  list: () => request.get('/address/list', {}),
  save: (data) => request.post('/address/save', data),
  remove: (id) => request.del('/address/' + id),
  setDefault: (id) => request.post('/address/' + id + '/default', {})
}

// 收藏（需登录）
export const favoriteApi = {
  list: (targetType) => request.get('/favorite/list', { targetType }),
  add: (data) => request.post('/favorite/add', data),
  remove: (data) => request.post('/favorite/remove', data),
  status: (targetType, targetId) => request.get('/favorite/status', { targetType, targetId })
}

// 课程（C 端公开列表 / 推荐；详情需登录）
export const courseApi = {
  list: (params) => request.get('/course/list', params).then(parsePage),
  recommend: (size = 5) => request.get('/course/recommend', { size }).then(r => (r && Array.isArray(r.list) ? r.list : (r && Array.isArray(r) ? r : []))),
  detail: (id) => request.get('/course/' + id, {}),
  channel: 'course',
  version: () => request.get('/sync/version?channel=course', {})
}

// 门店（公开列表 / 详情需登录）
export const storeApi = {
  list: (params) => request.get('/store/list', params).then(parsePage),
  detail: (id) => request.get('/store/' + id, {}),
  channel: 'store',
  version: () => request.get('/sync/version?channel=store', {})
}

// 服务（公开列表）
export const serviceApi = {
  list: (params) => request.get('/service/list', params).then(parsePage),
  detail: (id) => request.get('/service/' + id, {}),
  channel: 'service',
  version: () => request.get('/sync/version?channel=service', {})
}

// 活动（公开列表 / 详情需登录）
export const activityApi = {
  list: (params) => request.get('/activity/list', params).then(parsePage),
  detail: (id) => request.get('/activity/' + id, {}),
  channel: 'activity',
  version: () => request.get('/sync/version?channel=activity', {})
}

// 视频（公开列表 / 详情需登录）
export const videoApi = {
  list: (params) => request.get('/video/list', params).then(parsePage),
  detail: (id) => request.get('/video/' + id, {}),
  channel: 'video',
  version: () => request.get('/sync/version?channel=video', {})
}

// 资讯文章（公开列表 / 详情）
export const articleApi = {
  list: (params) => request.get('/article/published', params).then(parsePage),
  detail: (id) => request.get('/article/view/' + id, {}),
  channel: 'article',
  version: () => request.get('/sync/version?channel=article', {})
}

// 分类（公开）
export const categoryApi = {
  list: (params) => request.get('/category/list', params).then(parsePage),
  channel: 'category',
  version: () => request.get('/sync/version?channel=category', {})
}

// 轮播/banner（与管理端共用 /api/ad 接口，按 positionId 筛选首页轮播位）
export const bannerApi = {
  // C 端首页轮播：取 home_banner 位（positionId=1）启用中的广告，与管理端同数据源
  // 兼容旧调用 bannerApi.home('home_banner')：code 自动映射为 positionId
  home: (positionIdOrCode = 1) => {
    const positionId = positionIdOrCode === 'home_banner' ? 1 : (positionIdOrCode || 1)
    return request.get('/ad/list', { positionId, status: 1 }).then(parsePage).then(d => d.list)
  },
  channel: 'banner',
  // 轻量轮询：获取广告当前版本号
  version: () => request.get('/sync/version?channel=banner', {}),
  // SSE 实时推送地址（仅 H5 / App 可用，小程序走轮询）
  streamUrl: (channel = 'banner') => BASE_URL + '/sync/stream?channel=' + channel
}

// 通用实时同步（轮询版本号 + H5 SSE 推送），由各个列表页复用
export const syncApi = {
  version: (channel) => request.get('/sync/version?channel=' + channel, {}),
  streamUrl: (channel) => BASE_URL + '/sync/stream?channel=' + channel
}

// 订单（需登录）
export const orderApi = {
  list: (params) => request.get('/order/list', params).then(parsePage),
  create: (data) => request.post('/order/create', data),
  pay: (id) => request.post('/order/' + id + '/pay', {}),
  verify: (id) => request.post('/order/' + id + '/verify', {})
}

// AI 智能助手（公开问答 / 个性化推荐）
export const aiApi = {
  chat: (messages) => request.post('/ai/chat', { messages }, { timeout: 60000 }),
  recommend: (payload) => request.post('/ai/recommend', payload, { timeout: 60000 })
}

// 文件上传
export const uploadApi = {
  image: (filePath) => {
    const token = uni.getStorageSync('token')
    return new Promise((resolve, reject) => {
      // #ifndef H5
      uni.uploadFile({
        url: `${BASE_URL}/upload`,
        filePath,
        name: 'file',
        header: token ? { Authorization: `Bearer ${token}` } : {},
        timeout: 30000,
        success: (res) => {
          try {
            const body = JSON.parse(res.data)
            if (body.code !== undefined && body.code !== 0) return reject(new Error(body.msg || '上传失败'))
            resolve(body.data)
          } catch (e) { reject(e) }
        },
        fail: (err) => reject(err)
      })
      // #endif
      // #ifdef H5
      resolve(null)
      // #endif
    })
  }
}

export default {
  authApi, userApi, addressApi, favoriteApi, courseApi, storeApi, serviceApi,
  activityApi, videoApi, articleApi, categoryApi, bannerApi, orderApi, aiApi, uploadApi
}
