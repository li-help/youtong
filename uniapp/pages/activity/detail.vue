<template>
  <view class="detail" v-if="activity">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">活动详情</text>
      </view>
    </view>
    <image :src="coverOf(activity)" mode="aspectFill" class="banner" />
    <view class="body">
      <text class="title">{{ activity.title }}</text>
      <view class="meta">
        <text class="m-item">🕐 {{ activity.start_time || '时间待定' }}</text>
        <text class="m-item">📍 {{ activity.address || '优童活动中心' }}</text>
      </view>
      <view class="section">
        <view class="section-title">活动详情</view>
        <text class="intro text-muted">本活动由优童精心策划，邀请家庭共同参与，在专业老师引导下通过游戏、手工、互动体验等方式，增进亲子感情，促进孩子综合能力发展。</text>
      </view>
      <view class="section">
        <view class="section-title">活动流程</view>
        <view class="point">📌 签到入场 & 破冰互动</view>
        <view class="point">📌 主题游戏 & 亲子协作</view>
        <view class="point">📌 作品展示 & 合影留念</view>
      </view>
    </view>
    <view class="bottom-bar">
      <button class="btn-primary signup-btn" @click="onJoin">报名参加</button>
    </view>
  </view>
  <view v-else class="loading">加载中...</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { activityApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const activity = ref(null)
const id = ref('')

onMounted(() => {
  const pages = getCurrentPages()
  id.value = pages[pages.length - 1].options.id
  load()
})

async function load() {
  try {
    activity.value = await activityApi.detail(id.value)
  } catch (e) {
    activity.value = { id: id.value, title: '示例活动', address: '优童活动中心' }
  }
}

function onJoin() {
  uni.showToast({ title: '报名成功，请准时参加', icon: 'success' })
}
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.detail { padding-bottom: 150rpx; background: #F5F6FA; min-height: 100vh; }
.banner { width: 100%; height: 380rpx; background: #FFF3DE; }
.body { padding: 32rpx; }
.title { font-size: 40rpx; font-weight: bold; display: block; color: #2D2D2D; }
.meta { display: flex; flex-direction: column; margin: 24rpx 0; background: #fff; border-radius: 24rpx; padding: 24rpx 32rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.m-item { font-size: 26rpx; color: #888; margin: 8rpx 0; }
.section { margin-top: 36rpx; }
.intro { font-size: 28rpx; line-height: 1.7; color: #888; }
.point { font-size: 28rpx; color: #555; margin: 14rpx 0; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; padding: 18rpx 32rpx; padding-bottom: calc(18rpx + env(safe-area-inset-bottom)); background: #fff; box-shadow: 0 -6rpx 24rpx rgba(0,0,0,.06); }
.signup-btn { width: 100%; }
.loading { text-align: center; padding: 120rpx 0; color: #999; }
</style>
