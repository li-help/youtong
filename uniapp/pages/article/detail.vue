<template>
  <view class="article">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">学习天地</text>
      </view>
    </view>
    <scroll-view scroll-y class="scroll">
      <view class="list">
        <view class="card article-card" v-for="a in list" :key="a.id" @click="read(a)">
          <image :src="coverOf(a)" mode="aspectFill" class="a-cover" />
          <view class="a-info">
            <text class="a-title">{{ a.title }}</text>
            <text class="a-author text-muted">作者：{{ a.author || '优童教研' }}</text>
          </view>
        </view>
      </view>
      <view v-if="!list.length" class="empty">暂无内容</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { articleApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const list = ref([])
const catId = ref('')

onMounted(() => {
  const pages = getCurrentPages()
  catId.value = pages[pages.length - 1].options.id || ''
  load()
})

async function load() {
  try {
    const r = await articleApi.list({ page: 1, pageSize: 20, categoryId: catId.value || undefined })
    list.value = (r && r.list) ? r.list : []
  } catch (e) {
    list.value = []
    uni.showToast({ title: '内容加载失败，请稍后重试', icon: 'none' })
  }
}

function read(a) {
  uni.navigateTo({ url: '/pages/article/view?id=' + a.id })
}
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.article { min-height: 100vh; background: #F5F6FA; }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx)); padding: 24rpx 32rpx; }
.article-card { display: flex; align-items: center; }
.a-cover { width: 180rpx; height: 130rpx; border-radius: 16rpx; background: #FFF3DE; flex-shrink: 0; }
.a-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.a-title { font-size: 30rpx; font-weight: bold; color: #2D2D2D; }
.a-author { font-size: 24rpx; margin-top: 10rpx; color: #bbb; }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
