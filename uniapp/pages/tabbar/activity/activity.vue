<template>
  <view class="activity">
    <!-- 顶部标题 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">活动</text>
      </view>
    </view>

    <scroll-view scroll-y class="scroll" @refresherrefresh="onRefresh" :refresher-enabled="true" :refresher-triggered="refreshing">
      <!-- 分类筛选 -->
      <view class="filter-bar">
        <view class="filter-tag" :class="{ active: curFilter === '' }" @click="selectFilter('')">全部</view>
        <view class="filter-tag" :class="{ active: curFilter === 'ongoing' }" @click="selectFilter('ongoing')">进行中</view>
        <view class="filter-tag" :class="{ active: curFilter === 'upcoming' }" @click="selectFilter('upcoming')">即将开始</view>
      </view>

      <!-- 活动卡片列表 -->
      <view class="act-list">
        <view class="act-card" v-for="item in list" :key="item.id" @click="goDetail(item)">
          <image :src="coverOf(item)" mode="aspectFill" class="act-cover" />
          <view class="act-tag" v-if="item.status">{{ item.status }}</view>
          <view class="act-info">
            <text class="act-name">{{ item.title }}</text>
            <text class="act-time">🕐 {{ item.time || item.startTime || '时间待定' }}</text>
            <text class="act-loc">📍 {{ item.location || item.address || '线上/线下' }}</text>
            <view class="act-bottom">
              <text class="act-price">{{ item.price ? '¥' + item.price : '免费' }}</text>
              <text class="act-join">{{ item.joinCount || item.signupCount || 0 }}人参与</text>
            </view>
          </view>
        </view>
      </view>

      <view v-if="!list.length" class="empty">
        <text>暂无活动～</text>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { onShow, onHide } from '@dcloudio/uni-app'
import { activityApi } from '../../../api/index.js'
import { coverOf } from '../../../config.js'
import { useRealtime } from '../../../utils/realtime.js'

const list = ref([])
const curFilter = ref('')
const refreshing = ref(false)

async function loadList() {
  try {
    const params = { page: 1, pageSize: 20 }
    if (curFilter.value) params.status = curFilter.value
    const res = await activityApi.list(params)
    list.value = (res && res.list) ? res.list : []
  } catch (e) {
    list.value = []
  }
}

function selectFilter(f) {
  curFilter.value = f
  loadList()
}
function onRefresh() {
  refreshing.value = true
  loadList().finally(() => setTimeout(() => (refreshing.value = false), 600))
}
function goDetail(item) {
  uni.navigateTo({ url: '/pages/activity/detail?id=' + item.id })
}

// 后台活动变更时实时刷新
const realtime = useRealtime('activity', loadList)

onMounted(loadList)
onShow(() => realtime.start())
onHide(() => realtime.stop())
</script>

<style scoped>
.activity { min-height: 100vh; background: #F5F6FA; }
.scroll { height: calc(100vh - 88rpx); }

/* 筛选栏 */
.filter-bar { display: flex; gap: 16rpx; padding: 24rpx 32rpx; }
.filter-tag {
  padding: 14rpx 36rpx;
  border-radius: 30rpx;
  background: #fff;
  font-size: 26rpx; color: #777;
  border: 2rpx solid #EEEFF3;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,.03);
}
.filter-tag.active {
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  color: #fff; border-color: transparent;
  font-weight: bold;
  box-shadow: 0 6rpx 20rpx rgba(246,181,30,.28);
}

/* 活动列表 */
.act-list { padding: 0 32rpx; }
.act-card {
  position: relative;
  background: #fff;
  border-radius: 24rpx;
  overflow: hidden;
  margin-bottom: 28rpx;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,.05);
}
.act-cover { width: 100%; height: 280rpx; background: #EEEFF3; }
.act-tag {
  position: absolute; top: 16rpx; left: 16rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  color: #fff; font-size: 22rpx;
  padding: 6rpx 20rpx; border-radius: 20rpx;
  box-shadow: 0 4rpx 14rpx rgba(246,181,30,.30);
}
.act-info { padding: 24rpx 28rpx; }
.act-name { font-size: 32rpx; font-weight: bold; color: #2D2D2D; display: block; }
.act-time { font-size: 25rpx; color: #888; margin-top: 14rpx; display: block; }
.act-loc { font-size: 25rpx; color: #888; margin-top: 8rpx; display: block; }
.act-bottom {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 18rpx; padding-top: 18rpx;
  border-top: 2rpx solid #F5F6FA;
}
.act-price { font-size: 34rpx; font-weight: bold; color: #FF7043; }
.act-join { font-size: 23rpx; color: #bbb; }

.empty { text-align: center; padding: 80rpx 0; color: #bbb; font-size: 28rpx; }
.bottom-space { height: 40rpx; }
</style>
