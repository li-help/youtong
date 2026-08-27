import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '../router'

const service = axios.create({
  baseURL: '/api',
  // 线上经 Nginx 反代 + 公网链路，且后端部分接口（AI、大数据量列表）处理较慢，
  // 本地 10s 够用但线上容易超时，放宽到 30s
  timeout: 30000,
})

// 请求拦截：自动携带 JWT
service.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

let redirecting = false
function toLogin(msg) {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  if (!redirecting && router.currentRoute.value.path !== '/login') {
    redirecting = true
    ElMessage.error(msg || '登录已过期，请重新登录')
    router.replace('/login')
    setTimeout(() => (redirecting = false), 1000)
  }
}

service.interceptors.response.use(
  (res) => {
    const body = res.data
    // 后端统一返回 { code, msg, data }
    if (body && typeof body.code === 'number' && body.code !== 0) {
      // 业务码 401：未登录或过期
      if (body.code === 401) {
        toLogin(body.msg)
      } else {
        ElMessage.error(body.msg || '请求失败')
      }
      return Promise.reject(new Error(body.msg || '请求失败'))
    }
    // 成功：直接返回业务 data（列表场景为 { list, total, page, pageSize }）
    return body && typeof body.code === 'number' ? body.data : body
  },
  (err) => {
    if (err.response?.status === 401) {
      toLogin(err.response?.data?.msg || '登录已过期，请重新登录')
    } else {
      const msg =
        err.response?.data?.msg ||
        err.message ||
        '网络异常，请稍后重试'
      ElMessage.error(msg)
    }
    return Promise.reject(err)
  },
)

export default service
