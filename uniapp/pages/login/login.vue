<template>
  <view class="login-page">
    <view class="status-bar"></view>
    <view class="header">
      <view class="logo">
        <text class="logo-emoji">🧸</text>
      </view>
      <text class="app-name">优童</text>
      <text class="slogan">陪伴每一个成长的小宇宙</text>
    </view>

    <view class="form">
      <view class="input-item">
        <text class="icon">👤</text>
        <input class="input" v-model="username" placeholder="请输入账号" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <text class="icon">🔒</text>
        <input class="input" v-model="password" password placeholder="请输入密码" placeholder-class="ph" />
      </view>

      <button class="btn-primary submit" :loading="loading" @click="onLogin">登 录</button>

      <view class="links">
        <text @click="goRegister">没有账号？立即注册</text>
      </view>
    </view>

    <view class="tip">演示账号：输入任意账号密码即可体验（后端未启动时也可进入）</view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { userStore } from '../../store/user.js'

const username = ref('')
const password = ref('')
const loading = ref(false)

async function onLogin() {
  if (!username.value || !password.value) {
    uni.showToast({ title: '请输入账号和密码', icon: 'none' })
    return
  }
  loading.value = true
  try {
    await userStore.login(username.value, password.value)
    uni.showToast({ title: '登录成功', icon: 'success' })
    setTimeout(() => {
      uni.switchTab({ url: '/pages/tabbar/home/home' })
    }, 600)
  } catch (e) {
    // 后端未启动时，使用本地兜底登录以便预览
    uni.showModal({
      title: '登录提示',
      content: '后端未连接，是否以演示模式进入？',
      success: (res) => {
        if (res.confirm) {
          userStore.token = 'demo-token'
          userStore.info = { id: 1, username: username.value, nickname: username.value }
          uni.setStorageSync('token', 'demo-token')
          uni.switchTab({ url: '/pages/tabbar/home/home' })
        }
      }
    })
  } finally {
    loading.value = false
  }
}

function goRegister() {
  uni.navigateTo({ url: '/pages/register/register' })
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFE082 0%, #FFF8E1 60%);
  padding: 0 60rpx;
  display: flex;
  flex-direction: column;
}
.status-bar { height: 80rpx; }
.header { display: flex; flex-direction: column; align-items: center; margin: 80rpx 0 60rpx; }
.logo {
  width: 160rpx; height: 160rpx; border-radius: 50%;
  background: #fff; display: flex; align-items: center; justify-content: center;
  box-shadow: 0 10rpx 30rpx rgba(255,160,0,.3);
}
.logo-emoji { font-size: 90rpx; }
.app-name { font-size: 56rpx; font-weight: bold; color: #FF8F00; margin-top: 20rpx; }
.slogan { color: #B26A00; font-size: 26rpx; margin-top: 10rpx; }
.form { background: #fff; border-radius: 24rpx; padding: 48rpx 40rpx; box-shadow: 0 8rpx 30rpx rgba(255,160,0,.12); }
.input-item { display: flex; align-items: center; border-bottom: 2rpx solid #FFE0B2; padding: 24rpx 0; margin-bottom: 16rpx; }
.icon { font-size: 36rpx; margin-right: 20rpx; }
.input { flex: 1; font-size: 30rpx; }
.ph { color: #ccc; }
.submit { margin-top: 40rpx; }
.links { text-align: center; color: #FFA000; font-size: 26rpx; margin-top: 24rpx; }
.tip { text-align: center; color: #B26A00; font-size: 24rpx; margin-top: 40rpx; }
</style>
