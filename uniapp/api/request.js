// 统一请求封装：自动携带 token、统一错误提示、解析后端 R 结构。
// 说明：默认使用相对路径 '/api'，由 HBuilderX 运行 H5 时通过 manifest.h5.devServer.proxy 转发到后端。
// 在 App / 小程序真机调试时，请将下方 BASE_URL 改为你电脑的局域网 IP，例如：
//   const BASE_URL = 'http://192.168.1.100:3001/api'
// 当前工程默认以 H5 + 本地后端 (http://localhost:3001) 联调。
const BASE_URL = '/api'

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
      success: (res) => {
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
        if (body.code !== undefined && body.code !== 0) {
          uni.showToast({ title: body.msg || '请求失败', icon: 'none' })
          return reject(new Error(body.msg || '请求失败'))
        }
        resolve(body.data)
      },
      fail: (err) => {
        uni.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      }
    })
  })
}

export const get = (url, params = {}) => request({ url, method: 'GET', data: params })
export const post = (url, data = {}) => request({ url, method: 'POST', data })
export const put = (url, data = {}) => request({ url, method: 'PUT', data })
export const del = (url) => request({ url, method: 'DELETE' })

export default { get, post, put, del }
