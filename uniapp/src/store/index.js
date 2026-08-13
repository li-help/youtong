import { createStore } from 'vuex'
import { authApi, userApi } from '../api/index.js'

export default createStore({
  state: {
    token: uni.getStorageSync('token') || '',
    userInfo: uni.getStorageSync('userInfo') ? JSON.parse(uni.getStorageSync('userInfo')) : null
  },
  mutations: {
    SET_TOKEN(state, token) {
      state.token = token
      uni.setStorageSync('token', token)
    },
    SET_USER_INFO(state, info) {
      state.userInfo = info
      uni.setStorageSync('userInfo', JSON.stringify(info))
    },
    CLEAR_AUTH(state) {
      state.token = ''
      state.userInfo = null
      uni.removeStorageSync('token')
      uni.removeStorageSync('userInfo')
    }
  },
  actions: {
    async login({ commit }, { username, password }) {
      const res = await authApi.login(username, password)
      if (res.code === 0) {
        commit('SET_TOKEN', res.data.token)
        commit('SET_USER_INFO', res.data.user)
        return res
      }
      throw new Error(res.msg || '登录失败')
    },
    async fetchUserInfo({ commit }) {
      try {
        const res = await authApi.info()
        if (res.code === 0) {
          commit('SET_USER_INFO', res.data)
        }
      } catch (e) {
        console.error(e)
      }
    },
    logout({ commit }) {
      authApi.logout()
      commit('CLEAR_AUTH')
      uni.reLaunch({ url: '/pages/login/index' })
    }
  }
})
