<template>
  <view class="mine">
    <!-- 顶部标题 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">我的</text>
      </view>
    </view>

    <!-- Hero 头部 -->
    <view class="hero">
      <view class="hero-deco deco-a">⭐</view>
      <view class="hero-deco deco-b">🎈</view>
      <view class="hero-deco deco-c">✨</view>

      <view class="user-row" @click="goProfile">
        <view class="avatar-wrap">
          <text class="avatar-emoji">{{ isLoggedIn ? '😊' : '👤' }}</text>
        </view>
        <view class="user-info">
          <text class="nickname">{{ isLoggedIn ? (user.nickname || user.username || '优童用户') : '点击登录' }}</text>
          <text v-if="isLoggedIn" class="uid">ID: {{ user.id || '—' }}</text>
          <text v-else class="uid">登录后享受更多服务</text>
        </view>
        <text class="arrow">›</text>
      </view>

      <!-- 统计卡 -->
      <view class="stats">
        <view class="stat-item">
          <text class="stat-num">0</text>
          <text class="stat-label">我的订单</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">0</text>
          <text class="stat-label">我的收藏</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">100</text>
          <text class="stat-label">成长值</text>
        </view>
      </view>
    </view>

    <!-- 我的服务 -->
    <view class="service-section">
      <view class="service-header">
        <view class="service-icon">🎯</view>
        <text class="service-title">我的服务</text>
      </view>

      <view class="menu-list">
        <view class="menu-item" @click="goOrders">
          <view class="menu-icon-box mb-orange">📦</view>
          <text class="menu-text">我的订单</text>
          <view class="menu-right">
            <text class="menu-action">查看 ›</text>
          </view>
        </view>

        <view class="menu-item" @click="goQrcode">
          <view class="menu-icon-box mb-blue">📱</view>
          <text class="menu-text">我的二维码</text>
          <view class="menu-right">
            <text class="menu-action">查看 ›</text>
          </view>
        </view>

        <view class="menu-item" @click="goHelp">
          <view class="menu-icon-box mb-purple">📖</view>
          <text class="menu-text">使用说明</text>
          <view class="menu-right">
            <text class="menu-action">查看 ›</text>
          </view>
        </view>

        <view class="menu-item" @click="goProfile">
          <view class="menu-icon-box mb-green">👤</view>
          <text class="menu-text">个人信息</text>
          <view class="menu-right">
            <text class="menu-action">修改 ›</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部文案 -->
    <view class="footer-text">
      <text>🥰 陪伴宝宝快乐成长 🥰</text>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { userStore } from '../../../store/user.js'

const user = computed(() => userStore.info || {})
const isLoggedIn = computed(() => !!userStore.token)

function goProfile() { 
  if (!isLoggedIn.value) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  uni.navigateTo({ url: '/pages/mine/profile' }) 
}
function goOrders() { uni.navigateTo({ url: '/pages/order/list' }) }
function goQrcode() { uni.navigateTo({ url: '/pages/mine/qrcode' }) }
function goHelp() { uni.navigateTo({ url: '/pages/mine/help' }) }
</script>

<style scoped>
.mine { min-height: 100vh; background: #F5F6FA; }

/* Hero 头部 —— 改为柔和渐变，不再刺眼 */
.hero {
  position: relative;
  margin: 24rpx;
  padding: 36rpx 28rpx 0;
  background: linear-gradient(160deg, #FFE8B8, #FFD07A);
  border-radius: 28rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 28rpx rgba(255,180,60,.18);
}
.hero-deco { position: absolute; opacity: .25; }
.deco-a { top: 20rpx; right: 36rpx; font-size: 48rpx; transform: rotate(14deg); }
.deco-b { top: 80rpx; left: 26rpx; font-size: 38rpx; transform: rotate(-10deg); }
.deco-c { bottom: 140rpx; right: 80rpx; font-size: 30rpx; }

.user-row { display: flex; align-items: center; position: relative; }
.avatar-wrap {
  width: 104rpx; height: 104rpx; border-radius: 50%;
  background: linear-gradient(135deg, #E3F2FD, #BBDEFB);
  border: 5rpx solid rgba(255,255,255,.85);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 6rpx 20rpx rgba(0,0,0,.08);
}
.avatar-emoji { font-size: 50rpx; }
.user-info { flex: 1; margin-left: 22rpx; }
.nickname { font-size: 34rpx; font-weight: bold; color: #5D4000; display: block; }
.uid { font-size: 24rpx; color: rgba(93,64,0,.65); margin-top: 6rpx; display: block; }
.arrow { font-size: 44rpx; color: rgba(93,64,0,.55); }

/* 统计卡 */
.stats {
  display: flex;
  margin: 24rpx -28rpx 0;
  padding: 24rpx 0;
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
}
.stat-item { flex: 1; text-align: center; }
.stat-num { display: block; font-size: 38rpx; font-weight: bold; color: #E89B00; }
.stat-label { font-size: 22rpx; color: #999; margin-top: 4rpx; display: block; }

/* 服务区域 */
.service-section { margin: 24rpx 32rpx; }
.service-header { display: flex; align-items: center; margin-bottom: 24rpx; }
.service-icon { font-size: 30rpx; margin-right: 10rpx; }
.service-title { font-size: 33rpx; font-weight: bold; color: #2D2D2D; position: relative; padding-left: 24rpx; }
.service-title::before { content: ''; position: absolute; left: 0; top: 50%; transform: translateY(-50%); width: 8rpx; height: 32rpx; border-radius: 4rpx; background: linear-gradient(180deg, #FF9F2E, #F6B51E); }

.menu-list { background: #fff; border-radius: 24rpx; overflow: hidden; box-shadow: 0 4rpx 16rpx rgba(0,0,0,.04); }
.menu-item { display: flex; align-items: center; padding: 28rpx 24rpx; border-bottom: 2rpx solid #F5F6FA; }
.menu-item:last-child { border-bottom: none; }
.menu-icon-box { width: 64rpx; height: 64rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; font-size: 30rpx; margin-right: 20rpx; }
.mb-orange { background: linear-gradient(145deg, #FFE3C2, #FFC98A); }
.mb-blue { background: linear-gradient(145deg, #E3F2FD, #B9E3FA); }
.mb-purple { background: linear-gradient(145deg, #F3E5F5, #E0BBE4); }
.mb-green { background: linear-gradient(145deg, #E8F5E9, #C4E8C6); }
.menu-text { flex: 1; font-size: 29rpx; color: #2D2D2D; }
.menu-action { font-size: 26rpx; color: #bbb; }

/* 底部文案 */
.footer-text { text-align: center; padding: 60rpx 0 40rpx; }
.footer-text text { font-size: 27rpx; color: #E89B00; }
</style>