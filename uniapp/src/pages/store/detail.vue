<template>
  <view class="store" v-if="store">
    <view class="banner" :style="{ background: 'linear-gradient(135deg,#FFC107,#FF8F00)' }">
      <text class="s-emoji">🏫</text>
      <text class="s-name">{{ store.name }}</text>
      <text class="s-score">⭐ {{ store.score || '4.8' }}</text>
    </view>

    <view class="body">
      <view class="card">
        <view class="info-row"><text class="i-label">📍 地址</text><text class="i-val">{{ store.address || '优童教育园区' }}</text></view>
        <view class="info-row"><text class="i-label">📞 电话</text><text class="i-val">{{ store.phone || '400-000-0000' }}</text></view>
        <view class="info-row"><text class="i-label">🕐 营业</text><text class="i-val">09:00 - 21:00</text></view>
      </view>

      <view class="section">
        <view class="section-title">店铺介绍</view>
        <text class="intro text-muted">{{ store.intro || '本机构是优童认证优质教育服务门店，提供专业的儿童课程与活动，环境温馨、师资优良，深受家长信赖。' }}</text>
      </view>

      <view class="section">
        <view class="section-title">推荐课程</view>
        <view class="course-card" v-for="c in courses" :key="c.id" @click="goCourse(c)">
          <image :src="coverOf(c)" mode="aspectFill" class="c-cover" />
          <view class="c-info">
            <text class="c-title">{{ c.title }}</text>
            <text class="price">¥{{ c.price || '0' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
  <view v-else class="loading">加载中...</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { storeApi, courseApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const store = ref(null)
const courses = ref([])
const id = ref('')

onMounted(() => {
  const pages = getCurrentPages()
  id.value = pages[pages.length - 1].options.id
  load()
})

async function load() {
  try {
    store.value = await storeApi.detail(id.value)
    const r = await courseApi.list({ page: 1, pageSize: 3 })
    courses.value = (r && r.list) ? r.list : []
  } catch (e) {
    store.value = { id: id.value, name: '示例门店', score: '4.8', address: '优童教育园区' }
  }
}

function goCourse(c) { uni.navigateTo({ url: '/pages/course/detail?id=' + c.id }) }
</script>

<style scoped>
.store { min-height: 100vh; background: #FFF8E1; }
.banner { height: 280rpx; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #fff; }
.s-emoji { font-size: 90rpx; }
.s-name { font-size: 40rpx; font-weight: bold; margin-top: 10rpx; }
.s-score { font-size: 28rpx; margin-top: 10rpx; }
.body { padding: 24rpx; }
.info-row { display: flex; align-items: center; padding: 16rpx 0; border-bottom: 2rpx solid #FFF3E0; }
.i-label { width: 160rpx; font-size: 28rpx; color: #777; }
.i-val { flex: 1; font-size: 28rpx; color: #444; }
.section { margin-top: 30rpx; }
.intro { font-size: 28rpx; line-height: 1.7; }
.course-card { display: flex; align-items: center; background: #fff; border-radius: 16rpx; padding: 16rpx; margin-bottom: 16rpx; }
.c-cover { width: 140rpx; height: 100rpx; border-radius: 12rpx; background: #FFE0B2; }
.c-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.c-title { font-size: 28rpx; font-weight: bold; }
.loading { text-align: center; padding: 120rpx 0; color: #999; }
</style>
