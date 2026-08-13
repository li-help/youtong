import { reactive } from 'vue'
import { authApi } from '../api/index.js'

export const userStore = reactive({
  token: uni.getStorageSync('token') || '',
  info: uni.getStorageSync('userInfo') || null,

  async login(username, password) {
    const data = await authApi.login(username, password)
    this.token = data.token
    this.info = data.user
    uni.setStorageSync('token', data.token)
    uni.setStorageSync('userInfo', data.user)
    return data
  },

  async fetchInfo() {
    const data = await authApi.info()
    this.info = data
    uni.setStorageSync('userInfo', data)
    return data
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
