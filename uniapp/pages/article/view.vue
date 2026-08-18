<template>
  <view class="view">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">文章详情</text>
      </view>
    </view>
    <scroll-view scroll-y class="scroll">
      <view v-if="article" class="content card">
        <image v-if="coverOf(article)" :src="coverOf(article)" mode="aspectFill" class="cover" />
        <text class="title">{{ article.title }}</text>
        <text class="meta text-muted">作者：{{ article.author || '优童教研' }} · {{ article.createdAt || '' }}</text>
        <text class="body">{{ article.content || '暂无内容' }}</text>
      </view>
      <view v-else class="empty">加载中...</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { articleApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const article = ref(null)

onMounted(() => {
  const pages = getCurrentPages()
  const id = pages[pages.length - 1].options.id
  load(id)
})

async function load(id) {
  try {
    article.value = await articleApi.detail(id)
  } catch (e) {
    uni.showToast({ title: '文章加载失败', icon: 'none' })
  }
}

function goBack() { uni.navigateBack() }
</script>

<style scoped>
.view { min-height: 100vh; background: #F5F6FA; }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx)); padding: 24rpx 32rpx; }
.content { display: flex; flex-direction: column; }
.cover { width: 100%; height: 320rpx; border-radius: 18rpx; background: #FFF3DE; margin-bottom: 24rpx; }
.title { font-size: 38rpx; font-weight: bold; color: #2D2D2D; line-height: 1.5; }
.meta { font-size: 24rpx; margin-top: 14rpx; }
.body { font-size: 30rpx; color: #444; line-height: 1.9; margin-top: 28rpx; white-space: pre-wrap; }
.empty { text-align: center; color: #999; padding: 120rpx 0; }
</style>
