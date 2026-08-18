<template>
  <view class="register-page">
    <!-- 顶部导航 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="back-btn" @click="goBack">‹</text>
        <text class="app-nav__title">注册</text>
        <view class="nav-placeholder"></view>
      </view>
    </view>

    <!-- 头像区域 -->
    <view class="avatar-section">
      <view class="avatar-circle">
        <text class="avatar-icon">👤</text>
      </view>
      <text class="brand-slogan">优童成长 · 陪伴每一个小宇宙</text>
    </view>

    <!-- 表单区域 -->
    <view class="form-card">
      <view class="input-item">
        <input class="input" v-model="form.phone" placeholder="请输入手机号" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <input class="input" v-model="form.password" password placeholder="请输入密码" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <input class="input" v-model="form.confirmPwd" password placeholder="请再次输入密码" placeholder-class="ph" />
      </view>
      
      <!-- 验证码 -->
      <view class="code-row">
        <view class="input-item code-input">
          <input class="input" v-model="form.code" placeholder="请输入验证码" placeholder-class="ph" />
        </view>
        <button class="btn-code" :disabled="countdown > 0" @click="sendCode">
          {{ countdown > 0 ? countdown + 's' : '获取验证码' }}
        </button>
      </view>

      <button class="btn-register" :loading="loading" @click="onRegister">立即注册</button>

      <view class="form-links">
        <text class="link" @click="goLogin">已有账号？返回登录</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { authApi } from '../../api/index.js'

const form = reactive({
  phone: '',
  password: '',
  confirmPwd: '',
  code: ''
})
const loading = ref(false)
const countdown = ref(0)

function goBack() {
  uni.navigateBack()
}

function goLogin() {
  uni.navigateBack()
}

let timer = null
async function sendCode() {
  if (!form.phone) {
    uni.showToast({ title: '请输入手机号', icon: 'none' })
    return
  }
  if (form.phone.length !== 11) {
    uni.showToast({ title: '手机号格式不正确', icon: 'none' })
    return
  }
  try {
    const res = await authApi.sendCode(form.phone)
    countdown.value = 60
    timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) clearInterval(timer)
    }, 1000)
    // 演示环境后端直接返回验证码明文，便于联调
    const tip = (res && res.code) ? `验证码已发送（演示：${res.code}）` : '验证码已发送'
    uni.showToast({ title: tip, icon: 'none' })
  } catch (e) {
    // 错误提示已由 request 统一处理
  }
}

async function onRegister() {
  if (!form.phone || !form.password || !form.confirmPwd) {
    uni.showToast({ title: '请填写完整信息', icon: 'none' })
    return
  }
  if (form.password !== form.confirmPwd) {
    uni.showToast({ title: '两次密码不一致', icon: 'none' })
    return
  }
  if (!form.code) {
    uni.showToast({ title: '请输入验证码', icon: 'none' })
    return
  }
  loading.value = true
  try {
    await authApi.register(form.phone, form.password, form.phone, form.code)
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
.register-page { min-height: 100vh; background: #F5F6FA; }
.nav-placeholder { width: 60rpx; }
.back-btn { font-size: 56rpx; color: #2D2D2D; width: 60rpx; }

/* 头像区域 */
.avatar-section {
  display: flex; flex-direction: column; align-items: center;
  padding: 36rpx 0 28rpx;
}
.avatar-circle {
  width: 148rpx; height: 148rpx; border-radius: 50%;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border: 5rpx solid #fff;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 28rpx rgba(246,181,30,.22);
}
.avatar-icon { font-size: 68rpx; color: #fff; }
.brand-slogan {
  font-size: 27rpx; font-weight: 600;
  color: #E89B00; margin-top: 16rpx; letter-spacing: 1rpx;
}

/* 表单卡片 */
.form-card {
  margin: 10rpx 40rpx;
  background: #fff;
  border-radius: 24rpx;
  padding: 38rpx 32rpx 34rpx;
  box-shadow: 0 8rpx 32rpx rgba(0,0,0,.06);
}
.input-item {
  background: #F5F6FA;
  border: 2rpx solid #E8E8E8;
  border-radius: 16rpx;
  padding: 22rpx 28rpx;
  margin-bottom: 20rpx;
}
.input { font-size: 30rpx; color: #2D2D2D; }
.ph { color: #bbb; }

/* 验证码行 */
.code-row {
  display: flex; align-items: center; gap: 16rpx;
  margin-bottom: 24rpx;
}
.code-input { flex: 1; margin-bottom: 0; }
.btn-code {
  width: 220rpx; height: 76rpx; line-height: 76rpx;
  background: linear-gradient(135deg, #FFD54F, #FFB300);
  border-radius: 38rpx;
  font-size: 25rpx; color: #5D4000;
  border: none; white-space: nowrap; padding: 0;
}
.btn-code[disabled] { opacity: .55; }

.btn-register {
  height: 88rpx; line-height: 88rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border-radius: 44rpx;
  font-size: 33rpx; font-weight: bold; color: #fff;
  border: none;
  box-shadow: 0 6rpx 20rpx rgba(246,181,30,.25);
}

.form-links { text-align: center; margin-top: 20rpx; }
.link { color: #E89B00; font-size: 26rpx; }
</style>
