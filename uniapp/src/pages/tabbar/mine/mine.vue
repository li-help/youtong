<template>
  <view class="mine">
    <view class="status-bar"></view>
    <view class="header">
      <view class="user-row" @click="goProfile">
        <view class="avatar">{{ avatarText }}</view>
        <view class="user-info">
          <text class="nickname">{{ user.nickname || user.username || '优童用户' }}</text>
          <text class="uid text-muted">ID: {{ user.id || '—' }}</text>
        </view>
        <text class="arrow">›</text>
      </view>
    </view>

    <view class="menu">
      <view class="menu-item" @click="goOrders">
        <text class="m-icon">📋</text><text class="m-text">我的订单</text><text class="m-arrow">›</text>
      </view>
      <view class="menu-item" @click="goQrcode">
        <text class="m-icon">🔳</text><text class="m-text">我的二维码</text><text class="m-arrow">›</text>
      </view>
      <view class="menu-item" @click="goHelp">
        <text class="m-icon">📖</text><text class="m-text">使用说明</text><text class="m-arrow">›</text>
      </view>
      <view class="menu-item" @click="goProfile">
        <text class="m-icon">✏️</text><text class="m-text">修改个人信息</text><text class="m-arrow">›</text>
      </view>
      <view class="menu-item" @click="onLogout">
        <text class="m-icon">🚪</text><text class="m-text">退出登录</text><text class="m-arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { userStore } from '../../../store/user.js'

const user = computed(() => userStore.info || {})
const avatarText = computed(() => {
  const n = user.value.nickname || user.value.username || '童'
  return n.charAt(0)
})

function goProfile() { uni.navigateTo({ url: '/pages/mine/profile' }) }
function goOrders() { uni.navigateTo({ url: '/pages/order/list' }) }
function goQrcode() { uni.navigateTo({ url: '/pages/mine/qrcode' }) }
function goHelp() { uni.navigateTo({ url: '/pages/mine/help' }) }
function onLogout() {
  uni.showModal({
    title: '提示', content: '确定退出登录？', success: (r) => { if (r.confirm) userStore.logout() }
  })
}
</script>

<style scoped>
.mine { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { background: linear-gradient(135deg, #FFC107, #FFA000); padding: 40rpx 32rpx; }
.user-row { display: flex; align-items: center; }
.avatar { width: 110rpx; height: 110rpx; border-radius: 50%; background: #fff; color: #FF8F00; font-size: 48rpx; font-weight: bold; display: flex; align-items: center; justify-content: center; }
.user-info { flex: 1; margin-left: 24rpx; display: flex; flex-direction: column; }
.nickname { font-size: 36rpx; font-weight: bold; color: #fff; }
.uid { font-size: 24rpx; color: rgba(255,255,255,.8); margin-top: 6rpx; }
.arrow { color: #fff; font-size: 44rpx; }
.menu { background: #fff; margin: 24rpx; border-radius: 20rpx; overflow: hidden; }
.menu-item { display: flex; align-items: center; padding: 30rpx 28rpx; border-bottom: 2rpx solid #FFF3E0; }
.menu-item:last-child { border-bottom: none; }
.m-icon { font-size: 36rpx; margin-right: 20rpx; }
.m-text { flex: 1; font-size: 30rpx; color: #444; }
.m-arrow { color: #ccc; font-size: 36rpx; }
</style>
