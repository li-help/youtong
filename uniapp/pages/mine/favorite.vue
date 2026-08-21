<template>
  <view class="page">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">我的收藏</text>
      </view>
    </view>

    <view class="tabs">
      <view class="tab" :class="{ active: type === '' }" @click="change('')">全部</view>
      <view class="tab" :class="{ active: type === 'course' }" @click="change('course')">课程</view>
      <view class="tab" :class="{ active: type === 'activity' }" @click="change('activity')">活动</view>
      <view class="tab" :class="{ active: type === 'video' }" @click="change('video')">视频</view>
    </view>

    <scroll-view scroll-y class="scroll">
      <view class="fav-card" v-for="f in list" :key="f.id" @click="goDetail(f)">
        <image v-if="f.cover" class="fav-cover" :src="f.cover" mode="aspectFill" />
        <view class="fav-info">
          <text class="fav-title">{{ f.title || '—' }}</text>
          <view class="fav-bottom">
            <text class="fav-type">{{ typeText(f.targetType) }}</text>
            <text class="fav-del" @click.stop="onRemove(f)">取消收藏</text>
          </view>
        </view>
      </view>
      <view v-if="!list.length" class="empty">
        <text class="empty-icon">⭐</text>
        <text>还没有收藏内容</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { favoriteApi } from '../../api/index.js'

const type = ref('')
const list = ref([])

function typeText(t) {
  return { course: '课程', activity: '活动', video: '视频', article: '文章', store: '门店', service: '服务' }[t] || t
}

function detailUrl(f) {
  switch (f.targetType) {
    case 'course': return '/pages/course/detail?id=' + f.targetId
    case 'activity': return '/pages/activity/detail?id=' + f.targetId
    case 'video': return '/pages/video/play?id=' + f.targetId
    case 'article': return '/pages/article/detail?id=' + f.targetId
    case 'store': return '/pages/store/detail?id=' + f.targetId
    default: return ''
  }
}

async function load() {
  try {
    const r = await favoriteApi.list(type.value || '')
    list.value = r || []
  } catch (e) {
    list.value = []
    uni.showToast({ title: '加载失败，请稍后重试', icon: 'none' })
  }
}

function change(t) { type.value = t; load() }
function goBack() { uni.navigateBack() }
function goDetail(f) {
  const url = detailUrl(f)
  if (url) uni.navigateTo({ url })
}

function onRemove(f) {
  uni.showModal({
    title: '取消收藏',
    content: '确定取消收藏「' + (f.title || '该内容') + '」吗？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await favoriteApi.remove({ targetType: f.targetType, targetId: f.targetId })
        uni.showToast({ title: '已取消收藏', icon: 'none' })
        load()
      } catch (e) {
        uni.showToast({ title: '操作失败，请稍后重试', icon: 'none' })
      }
    }
  })
}

onShow(load)
</script>

<style scoped>
.page { min-height: 100vh; background: #F5F6FA; }
.tabs { display: flex; gap: 16rpx; padding: 24rpx 32rpx; }
.tab { flex: 1; text-align: center; font-size: 28rpx; color: #888; padding: 14rpx 0; background: #fff; border-radius: 36rpx; box-shadow: 0 4rpx 14rpx rgba(0,0,0,0.03); }
.tab.active { color: #fff; font-weight: bold; background: linear-gradient(135deg, #FF9F2E, #F6B51E); box-shadow: 0 8rpx 24rpx rgba(246,181,30,0.30); }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx) - 120rpx); padding: 0 32rpx; }
.fav-card { display: flex; background: #fff; border-radius: 24rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.04); padding: 24rpx; margin-bottom: 24rpx; }
.fav-cover { width: 140rpx; height: 140rpx; border-radius: 16rpx; background: #F0F0F0; flex-shrink: 0; }
.fav-info { flex: 1; margin-left: 24rpx; display: flex; flex-direction: column; justify-content: space-between; overflow: hidden; }
.fav-title { font-size: 30rpx; font-weight: 600; color: #2D2D2D; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; }
.fav-bottom { display: flex; align-items: center; justify-content: space-between; }
.fav-type { font-size: 24rpx; color: #E89B00; background: #FFF6E5; padding: 4rpx 16rpx; border-radius: 20rpx; }
.fav-del { font-size: 24rpx; color: #999; }
.empty { display: flex; flex-direction: column; align-items: center; gap: 16rpx; }
.empty-icon { font-size: 80rpx; }
</style>
