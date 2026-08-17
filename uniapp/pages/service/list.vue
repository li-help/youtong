<template>
  <view class="service">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">服务</text>
      </view>
    </view>

    <view class="search-bar">
      <input class="search-input" v-model="keyword" placeholder="搜索服务" placeholder-class="ph"
             @confirm="onSearch" @input="onInput" />
    </view>

    <scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
      <view class="grid">
        <view class="card service-card" v-for="s in list" :key="s.id" @click="open(s)">
          <image :src="coverOf(s)" mode="aspectFill" class="s-cover" />
          <view class="s-info">
            <text class="s-title">{{ s.title || s.name }}</text>
            <text class="s-price">¥{{ s.price || '0' }}</text>
            <text class="s-desc text-muted">{{ (s.intro || s.summary || '').slice(0, 24) }}</text>
          </view>
        </view>
      </view>
      <view v-if="!list.length && !loading" class="empty">暂无服务</view>
      <view v-if="loading" class="loading">加载中...</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { onShow, onHide } from '@dcloudio/uni-app'
import { serviceApi } from '../../api/index.js'
import { coverOf } from '../../config.js'
import { useRealtime } from '../../utils/realtime.js'

const list = ref([])
const page = ref(1)
const pageSize = 10
const total = ref(0)
const keyword = ref('')
const loading = ref(false)

// 后台服务变更时实时刷新
const realtime = useRealtime('service', () => load(true))

onMounted(load)
onShow(() => realtime.start())
onHide(() => realtime.stop())

async function load(reset = false) {
  if (reset) { page.value = 1; list.value = [] }
  loading.value = true
  try {
    const r = await serviceApi.list({ page: page.value, pageSize, keyword: keyword.value || undefined })
    const rows = (r && r.list) ? r.list : []
    total.value = (r && r.total) || 0
    list.value = reset ? rows : list.value.concat(rows)
  } catch (e) {
    // 错误提示已由 request 统一处理
  } finally {
    loading.value = false
  }
}

function loadMore() {
  if (list.value.length >= total.value) return
  page.value += 1
  load(false)
}

function onSearch() { load(true) }
function onInput() { if (!keyword.value) load(true) }

function open(s) {
  uni.showModal({ title: s.title || s.name || '服务', content: s.intro || s.summary || '暂无介绍', showCancel: false })
}
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.service { min-height: 100vh; background: #F5F6FA; }
.search-bar { padding: 24rpx 32rpx 16rpx; }
.search-input { background: #fff; border-radius: 36rpx; padding: 18rpx 30rpx; font-size: 28rpx; box-shadow: 0 4rpx 14rpx rgba(0,0,0,0.04); }
.ph { color: #ccc; }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx) - 140rpx); padding: 0 32rpx; }
.grid { display: flex; flex-wrap: wrap; justify-content: space-between; }
.service-card { width: 48%; margin-bottom: 20rpx; }
.s-cover { width: 100%; height: 200rpx; border-radius: 16rpx; background: #FFF3DE; }
.s-info { padding: 12rpx 8rpx 16rpx; }
.s-title { font-size: 28rpx; font-weight: bold; display: block; color: #2D2D2D; }
.s-price { font-size: 28rpx; color: #E89B00; font-weight: bold; display: block; margin-top: 6rpx; }
.s-desc { font-size: 22rpx; display: block; margin-top: 6rpx; color: #bbb; }
.empty, .loading { text-align: center; color: #999; padding: 60rpx 0; }
</style>
