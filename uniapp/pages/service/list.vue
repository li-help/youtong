<template>
  <view class="service">
    <view class="status-bar"></view>
    <view class="header">
      <text class="back" @click="goBack">‹</text>
      <text class="title">服务</text>
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
import { serviceApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const list = ref([])
const page = ref(1)
const pageSize = 10
const total = ref(0)
const keyword = ref('')
const loading = ref(false)

onMounted(load)

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
.service { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { display: flex; align-items: center; padding: 16rpx 24rpx 24rpx; }
.back { font-size: 56rpx; color: #FF8F00; width: 60rpx; }
.title { font-size: 38rpx; font-weight: bold; color: #FF8F00; margin-left: 16rpx; }
.search-bar { padding: 0 24rpx 16rpx; }
.search-input { background: #fff; border-radius: 40rpx; padding: 16rpx 28rpx; font-size: 28rpx; }
.ph { color: #ccc; }
.scroll { height: calc(100vh - 280rpx); padding: 0 24rpx; }
.grid { display: flex; flex-wrap: wrap; justify-content: space-between; }
.service-card { width: 48%; margin-bottom: 20rpx; }
.s-cover { width: 100%; height: 200rpx; border-radius: 16rpx; background: #FFE0B2; }
.s-info { padding: 12rpx 8rpx 16rpx; }
.s-title { font-size: 28rpx; font-weight: bold; display: block; }
.s-price { font-size: 28rpx; color: #FF6F00; font-weight: bold; display: block; margin-top: 6rpx; }
.s-desc { font-size: 22rpx; display: block; margin-top: 6rpx; }
.empty, .loading { text-align: center; color: #999; padding: 60rpx 0; }
</style>
