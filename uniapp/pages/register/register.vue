<template>
  <view class="register-page">
    <view class="status-bar"></view>
    <view class="top-bar">
      <text class="back" @click="goBack">‹</text>
      <text class="title">注册账号</text>
    </view>

    <view class="form">
      <view class="input-item">
        <text class="icon">👤</text>
        <input class="input" v-model="form.username" placeholder="设置登录账号" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <text class="icon">✨</text>
        <input class="input" v-model="form.nickname" placeholder="昵称" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <text class="icon">🔒</text>
        <input class="input" v-model="form.password" password placeholder="设置密码" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <text class="icon">👶</text>
        <input class="input" v-model="form.babyAge" type="number" placeholder="宝宝年龄(岁)" placeholder-class="ph" />
      </view>

      <button class="btn-primary submit" :loading="loading" @click="onRegister">注 册</button>
    </view>
    <view class="tip">注册信息将保存到本地演示（后端未启动时使用本地存储）</view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { authApi } from '../../api/index.js'

const form = ref({ username: '', nickname: '', password: '', babyAge: '' })
const loading = ref(false)

function goBack() {
  uni.navigateBack()
}

async function onRegister() {
  if (!form.value.username || !form.value.password) {
    uni.showToast({ title: '账号和密码必填', icon: 'none' })
    return
  }
  loading.value = true
  try {
    await authApi.register(form.value.username, form.value.password, form.value.nickname || form.value.username)
    uni.showToast({ title: '注册成功，请登录', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 600)
  } catch (e) {
    // 错误提示已由 request 统一处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page { min-height: 100vh; background: linear-gradient(180deg, #FFE082 0%, #FFF8E1 60%); padding: 0 60rpx; }
.status-bar { height: 80rpx; }
.top-bar { display: flex; align-items: center; padding: 20rpx 0 40rpx; }
.back { font-size: 56rpx; color: #FF8F00; width: 60rpx; }
.title { font-size: 40rpx; font-weight: bold; color: #FF8F00; margin-left: 20rpx; }
.form { background: #fff; border-radius: 24rpx; padding: 48rpx 40rpx; box-shadow: 0 8rpx 30rpx rgba(255,160,0,.12); }
.input-item { display: flex; align-items: center; border-bottom: 2rpx solid #FFE0B2; padding: 24rpx 0; margin-bottom: 16rpx; }
.icon { font-size: 36rpx; margin-right: 20rpx; }
.input { flex: 1; font-size: 30rpx; }
.ph { color: #ccc; }
.submit { margin-top: 40rpx; }
.tip { text-align: center; color: #B26A00; font-size: 24rpx; margin-top: 40rpx; }
</style>
