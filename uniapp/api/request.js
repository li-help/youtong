// 统一请求封装：自动携带 token、统一错误提示、解析后端 R 结构。
// 自动区分运行环境：
//   - H5：使用相对路径 '/api'，由 manifest.h5.devServer.proxy 转发到后端（http://localhost:3001）
//   - 微信开发者工具：用 127.0.0.1，工具本身就在本机运行，可直达后端
//   - 真机调试：改成你电脑的局域网 IP（如 192.168.x.x），确保手机与电脑同 WiFi
const SERVER_IP = '127.0.0.1' // ← 微信开发者工具用本机；真机调试改局域网 IP
const SERVER_BASE = `http://${SERVER_IP}:3001/api`

// #ifdef H5
const BASE_URL = '/api'
// #endif
// #ifndef H5
const BASE_URL = SERVER_BASE
// #endif

function request(options) {
  const token = uni.getStorageSync('token')
  return new Promise((resolve, reject) => {
    uni.request({
      url: `${BASE_URL}${options.url}`,
      method: options.method || 'GET',
      data: options.data || {},
      header: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...(options.header || {})
      },
      timeout: options.timeout || 8000,
      success: (res) => {
        console.log('[request] success', BASE_URL + options.url, res.statusCode, JSON.stringify(res.data))
        if (res.statusCode >= 500) {
          uni.showToast({ title: '服务器繁忙，请稍后再试', icon: 'none' })
          return reject(new Error(`Server error ${res.statusCode}`))
        }
        if (res.statusCode === 401) {
          uni.removeStorageSync('token')
          uni.removeStorageSync('userInfo')
          uni.showToast({ title: '登录已过期', icon: 'none' })
          setTimeout(() => {
            uni.reLaunch({ url: '/pages/login/login' })
          }, 800)
          return reject(new Error('Unauthorized'))
        }
        if (res.statusCode >= 400) {
          const msg = res.data?.msg || res.data?.message || `请求失败(${res.statusCode})`
          uni.showToast({ title: msg, icon: 'none' })
          return reject(new Error(msg))
        }
        const body = res.data || {}
        // 业务码 401：未登录或登录过期，与管理端一致处理（清 token、跳登录）
        if (body.code === 401) {
          uni.removeStorageSync('token')
          uni.removeStorageSync('userInfo')
          uni.showToast({ title: body.msg || '登录已过期', icon: 'none' })
          setTimeout(() => {
            uni.reLaunch({ url: '/pages/login/login' })
          }, 800)
          return reject(new Error(body.msg || 'Unauthorized'))
        }
        if (body.code !== undefined && body.code !== 0) {
          uni.showToast({ title: body.msg || '请求失败', icon: 'none' })
          return reject(new Error(body.msg || '请求失败'))
        }
        // 标准 {code,msg,data} 解出 data；非标准响应（无 code 字段）直接返回 body，与管理端一致
        resolve(body.code !== undefined ? body.data : body)
      },
      fail: (err) => {
        console.error('[request] fail', BASE_URL + options.url, JSON.stringify(err))
        uni.showToast({ title: '网络错误:' + (err.errMsg || ''), icon: 'none' })
        reject(err)
      },
      complete: () => {
        console.log('[request] complete', BASE_URL + options.url)
      }
    })
  })
}

export const get = (url, params = {}) => request({ url, method: 'GET', data: params })
export const post = (url, data = {}) => request({ url, method: 'POST', data })
export const put = (url, data = {}) => request({ url, method: 'PUT', data })
export const del = (url) => request({ url, method: 'DELETE' })

export { BASE_URL }
export default { get, post, put, del }
