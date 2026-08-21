<template>
  <view class="scan-confirm-page">
    <view class="card" v-if="!done">
      <view class="header-icon">📷</view>
      <text class="title">扫码登录确认</text>
      <text class="desc">确认登录「优童成长社」电脑端网页吗？</text>
      <button class="btn-confirm" :loading="loading" @click="onConfirm">确认登录</button>
      <text class="tip">仅用于在电脑端网页登录，请确认是本人在操作</text>
    </view>
    <view class="card" v-else>
      <view class="header-icon ok">✅</view>
      <text class="title">已确认</text>
      <text class="desc">请返回电脑端网页，即将自动完成登录</text>
      <button class="btn-exit" @click="exit">退出小程序</button>
    </view>
  </view>
</template>

<script>
import { authApi } from '../../api/index.js'

export default {
  data() {
    return {
      ticket: '',
      loading: false,
      done: false
    }
  },
  onLoad(options) {
    // 小程序码 scene 携带 ticket；个别场景下微信会做 URL 编码，这里兼容处理
    let scene = options.scene || options.ticket || ''
    try { scene = decodeURIComponent(scene) } catch (e) {}
    this.ticket = scene
    if (!this.ticket) {
      uni.showToast({ title: '缺少登录凭证', icon: 'none' })
      setTimeout(() => uni.navigateBack({ fail: () => {} }), 800)
      return
    }
    // 进入页面即标记"已扫码"，让电脑端及时给出提示
    authApi.scanMarked(this.ticket).catch(() => {})
  },
  methods: {
    onConfirm() {
      if (this.loading || this.done) return
      this.loading = true
      uni.login({
        success: async (res) => {
          if (!res.code) {
            this.loading = false
            uni.showToast({ title: '获取微信凭证失败', icon: 'none' })
            return
          }
          try {
            await authApi.scanConfirm(this.ticket, res.code)
            this.loading = false
            this.done = true
          } catch (e) {
            this.loading = false
            const msg = (e && (e.errMsg || e.message || '确认失败')) || '确认失败'
            uni.showModal({ title: '确认失败', content: msg, showCancel: false })
          }
        },
        fail: (err) => {
          this.loading = false
          uni.showModal({
            title: '确认失败',
            content: (err && err.errMsg) || '调用微信登录失败',
            showCancel: false
          })
        }
      })
    },
    exit() {
      // #ifdef MP-WEIXIN
      uni.exitMiniProgram()
      // #endif
      // #ifndef MP-WEIXIN
      uni.navigateBack({ fail: () => {} })
      // #endif
    }
  }
}
</script>

<style scoped>
.scan-confirm-page {
  min-height: 100vh;
  background: #FFF9EC;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
  box-sizing: border-box;
}
.card {
  width: 100%;
  max-width: 600rpx;
  background: #fff;
  border-radius: 28rpx;
  padding: 70rpx 48rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: 0 8rpx 32rpx rgba(0,0,0,.06);
}
.header-icon {
  width: 120rpx; height: 120rpx;
  border-radius: 50%;
  background: #FFF3D6;
  font-size: 56rpx;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 28rpx;
}
.header-icon.ok { background: #E6F9EE; }
.title { font-size: 36rpx; font-weight: bold; color: #2D2D2D; }
.desc { font-size: 27rpx; color: #777; margin-top: 18rpx; text-align: center; }
.btn-confirm {
  margin-top: 48rpx;
  width: 100%;
  height: 92rpx; line-height: 92rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border-radius: 46rpx;
  font-size: 32rpx; font-weight: bold; color: #fff;
  border: none;
  box-shadow: 0 6rpx 20rpx rgba(246,181,30,.25);
}
.btn-exit {
  margin-top: 48rpx;
  width: 100%;
  height: 92rpx; line-height: 92rpx;
  background: #07C160;
  border-radius: 46rpx;
  font-size: 32rpx; font-weight: bold; color: #fff;
  border: none;
}
.tip { font-size: 23rpx; color: #aaa; margin-top: 26rpx; text-align: center; }
</style>
