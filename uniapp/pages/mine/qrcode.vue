<template>
  <view class="qrcode">
    <view class="status-bar"></view>
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
</script>

<style scoped>
.qrcode { min-height: 100vh; background: #FFF8E1; padding: 80rpx 40rpx; }
.status-bar { height: 80rpx; }
.card { background: #fff; border-radius: 24rpx; padding: 40rpx; }
.user-row { display: flex; align-items: center; }
.avatar { width: 100rpx; height: 100rpx; border-radius: 50%; background: linear-gradient(135deg,#FFC107,#FFA000); color: #fff; font-size: 44rpx; font-weight: bold; display: flex; align-items: center; justify-content: center; }
.u-info { margin-left: 24rpx; display: flex; flex-direction: column; }
.nickname { font-size: 34rpx; font-weight: bold; }
.uid { font-size: 24rpx; margin-top: 6rpx; }
.qr-box { display: flex; flex-direction: column; align-items: center; margin: 40rpx 0; }
.qr-placeholder { width: 360rpx; height: 360rpx; border: 4rpx solid #FFE0B2; border-radius: 20rpx; display: flex; align-items: center; justify-content: center; background: #FFF8E1; }
.qr-emoji { font-size: 160rpx; }
.qr-tip { font-size: 26rpx; color: #999; margin-top: 20rpx; }
.code-text { text-align: center; font-size: 28rpx; color: #FF8F00; font-weight: bold; }
</style>
