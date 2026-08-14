<template>
  <view class="activity">
    <view class="status-bar"></view>
    <view class="header">
      <text class="title">活动</text>
    </view>

    <scroll-view scroll-y class="scroll" @refresherrefresh="onRefresh" :refresher-enabled="true" :refresher-triggered="refreshing">
      <view class="card act-card" v-for="a in list" :key="a.id" @click="goDetail(a)">
        <image :src="coverOf(a)" mode="aspectFill" class="a-cover" />
        <view class="a-body">
          <text class="a-title">{{ a.title }}</text>
          <view class="a-meta">
            <text class="a-time">🕐 {{ a.start_time || '时间待定' }}</text>
            <text class="a-status" v-if="a.status === 1">报名中</text>
          </view>
          <text class="a-desc text-muted">{{ a.intro || '精彩亲子活动，快来参与吧～' }}</text>
        </view>
      </view>
      <view v-if="!list.length" class="empty">暂无活动数据</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { activityApi } from '../../../api/index.js'
import { coverOf } from '../../../config.js'

const list = ref([])
const refreshing = ref(false)

async function loadList() {
  try {
    const r = await activityApi.list({ page: 1, pageSize: 20 })
    list.value = (r && r.list) ? r.list : []
  } catch (e) { list.value = [] }
}
function onRefresh() {
  refreshing.value = true
  loadList().finally(() => setTimeout(() => (refreshing.value = false), 500))
}
function goDetail(a) { uni.navigateTo({ url: '/pages/activity/detail?id=' + a.id }) }

onMounted(loadList)
</script>

<style scoped>
.activity { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { padding: 20rpx 24rpx; }
.title { font-size: 40rpx; font-weight: bold; color: #FF8F00; }
.scroll { height: calc(100vh - 180rpx); padding: 0 24rpx; }
.act-card { display: flex; }
.a-cover { width: 220rpx; height: 160rpx; border-radius: 16rpx; background: #FFE0B2; flex-shrink: 0; }
.a-body { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.a-title { font-size: 30rpx; font-weight: bold; }
.a-meta { display: flex; align-items: center; justify-content: space-between; margin: 10rpx 0; }
.a-time { font-size: 24rpx; color: #777; }
.a-status { font-size: 22rpx; color: #fff; background: #FFA000; border-radius: 20rpx; padding: 2rpx 16rpx; }
.a-desc { font-size: 24rpx; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
