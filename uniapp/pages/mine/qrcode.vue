<template>
  <view class="qrcode">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">我的二维码</text>
      </view>
    </view>
    <view class="card">
      <view class="user-row">
        <view class="avatar">{{ avatarText }}</view>
        <view class="u-info">
          <text class="nickname">{{ user.nickname || user.username || '优童用户' }}</text>
          <text class="uid text-muted">ID: {{ user.id || '—' }}</text>
        </view>
      </view>

      <view class="qr-box">
        <!-- 用 emoji 占位二维码（真实项目可用 uQRCode 生成） -->
        <view class="qr-placeholder">
          <text class="qr-emoji">🔳</text>
        </view>
        <text class="qr-tip">扫一扫，添加好友 / 核销身份</text>
      </view>

      <view class="code-text">优童身份码：{{ code }}</view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { userStore } from '../../store/user.js'

const user = computed(() => userStore.info || {})
const avatarText = computed(() => {
  const n = user.value.nickname || user.value.username || '童'
  return n.charAt(0)
})
const code = computed(() => 'YT' + (user.value.id || '0') + '8F2A')

function goBack() { uni.navigateBack() }
</script>

<style scoped>
.qrcode { min-height: 100vh; background: #F5F6FA; padding: 40rpx 32rpx; }
.card { background: #fff; border-radius: 32rpx; padding: 40rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.user-row { display: flex; align-items: center; }
.avatar { width: 100rpx; height: 100rpx; border-radius: 50%; background: linear-gradient(135deg, #FF9F2E, #F6B51E); color: #fff; font-size: 44rpx; font-weight: bold; display: flex; align-items: center; justify-content: center; }
.u-info { margin-left: 24rpx; display: flex; flex-direction: column; }
.nickname { font-size: 34rpx; font-weight: bold; color: #2D2D2D; }
.uid { font-size: 24rpx; margin-top: 6rpx; color: #bbb; }
.qr-box { display: flex; flex-direction: column; align-items: center; margin: 40rpx 0; }
.qr-placeholder { width: 360rpx; height: 360rpx; border: 4rpx dashed #F6B51E; border-radius: 24rpx; display: flex; align-items: center; justify-content: center; background: #FFF3DE; }
.qr-emoji { font-size: 160rpx; }
.qr-tip { font-size: 26rpx; color: #bbb; margin-top: 20rpx; }
.code-text { text-align: center; font-size: 28rpx; color: #E89B00; font-weight: bold; }
</style>
