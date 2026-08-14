<template>
  <view class="article">
    <view class="status-bar"></view>
    <view class="header">
      <text class="back" @click="goBack">‹</text>
      <text class="title">学习天地</text>
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
    list.value = [
      { id: 1, title: '如何培养孩子阅读习惯', author: '优童教研' },
      { id: 2, title: '0-3岁感官启蒙指南', author: '优童教研' },
      { id: 3, title: '亲子沟通的3个小技巧', author: '优童教研' }
    ]
  }
}

function read(a) {
  uni.showModal({ title: a.title, content: '这里是《' + a.title + '》的详细内容（演示）。', showCancel: false })
}
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.article { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { display: flex; align-items: center; padding: 16rpx 24rpx 24rpx; }
.back { font-size: 56rpx; color: #FF8F00; width: 60rpx; }
.title { font-size: 38rpx; font-weight: bold; color: #FF8F00; margin-left: 16rpx; }
.scroll { height: calc(100vh - 200rpx); padding: 0 24rpx; }
.article-card { display: flex; align-items: center; }
.a-cover { width: 180rpx; height: 130rpx; border-radius: 14rpx; background: #FFE0B2; flex-shrink: 0; }
.a-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.a-title { font-size: 30rpx; font-weight: bold; }
.a-author { font-size: 24rpx; margin-top: 10rpx; }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
