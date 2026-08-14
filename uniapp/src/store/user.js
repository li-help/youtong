import { reactive } from 'vue'
import { authApi } from '../api/index.js'

export const userStore = reactive({
  token: uni.getStorageSync('token') || '',
  info: uni.getStorageSync('userInfo') || null,

  async login(username, password) {
    const data = (await authApi.login(username, password)) || {}
    this.token = data.token || ''
    this.info = data.user || null
    uni.setStorageSync('token', this.token)
    uni.setStorageSync('userInfo', this.info)
    return data
  },

  async fetchInfo() {
    const info = await authApi.info()
    this.info = info || null
    uni.setStorageSync('userInfo', this.info)
    return this.info
  },

  logout() {
    try { authApi.logout() } catch (e) {}
    this.token = ''
    this.info = null
    uni.removeStorageSync('token')
    uni.removeStorageSync('userInfo')
    uni.reLaunch({ url: '/pages/login/login' })
  }
})
