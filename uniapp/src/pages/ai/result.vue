<template>
  <view class="result">
    <view class="status-bar"></view>
    <view class="header">
      <text class="title">为您推荐</text>
      <text class="sub">根据宝宝 {{ age }}岁 · 身高{{ height }}cm · 体重{{ weight }}kg</text>
    </view>

    <scroll-view scroll-y class="scroll">
      <view class="summary card">
        <text class="summary-text">{{ summary }}</text>
      </view>

      <view class="section">
        <view class="section-title">推荐课程</view>
        <view class="card course-card" v-for="c in courses" :key="c.id" @click="goCourse(c)">
          <image :src="coverOf(c)" mode="aspectFill" class="c-cover" />
          <view class="c-info">
            <text class="c-title">{{ c.title }}</text>
            <text class="c-teacher text-muted">讲师：{{ c.teacher || '优童名师' }}</text>
            <text class="price">¥{{ c.price || '0' }}</text>
          </view>
        </view>
      </view>

      <view class="section">
        <view class="section-title">推荐活动</view>
        <view class="card activity-card" v-for="a in activities" :key="a.id" @click="goActivity(a)">
          <image :src="coverOf(a)" mode="aspectFill" class="a-cover" />
          <view class="a-info">
            <text class="a-title">{{ a.title }}</text>
            <text class="a-time text-muted">{{ a.startTime || '时间待定' }}</text>
          </view>
        </view>
      </view>

      <view class="section">
        <view class="section-title">推荐视频</view>
        <view class="card video-card" v-for="v in videos" :key="v.id" @click="goVideo(v)">
          <image :src="coverOf(v)" mode="aspectFill" class="v-cover" />
          <view class="v-info">
            <text class="v-title">{{ v.title }}</text>
            <text class="v-dur text-muted">时长 {{ v.duration || 0 }} 秒</text>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { courseApi, activityApi, videoApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const age = ref('')
const height = ref('')
const weight = ref('')
const interests = ref([])
const summary = ref('')
const courses = ref([])
const activities = ref([])
const videos = ref([])

onMounted(() => {
  const q = uni.getSystemInfoSync ? {} : {}
  const pages = getCurrentPages()
  const opt = pages[pages.length - 1].options
  age.value = opt.age || ''
  height.value = opt.height || ''
  weight.value = opt.weight || ''
  interests.value = opt.interests ? decodeURIComponent(opt.interests).split(',') : []
  summary.value = `结合宝宝当前成长阶段（${age.value}岁）及兴趣偏好，我们为您精选了以下${interests.value.join('、') || '综合素养'}相关的内容，助力全面发展。`
  loadData()
})

async function loadData() {
  try {
    const [c, a, v] = await Promise.all([
      courseApi.list({ page: 1, pageSize: 4 }),
      activityApi.list({ page: 1, pageSize: 3 }),
      videoApi.list({ page: 1, pageSize: 3 })
    ])
    courses.value = (c && c.list) ? c.list : []
    activities.value = (a && a.list) ? a.list : []
    videos.value = (v && v.list) ? v.list : []
  } catch (e) {}
}

function goCourse(c) { uni.navigateTo({ url: '/pages/course/detail?id=' + c.id }) }
function goActivity(a) { uni.navigateTo({ url: '/pages/activity/detail?id=' + a.id }) }
function goVideo(v) { uni.navigateTo({ url: '/pages/video/play?id=' + v.id }) }
</script>

<style scoped>
.result { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { padding: 20rpx 24rpx 10rpx; }
.title { font-size: 40rpx; font-weight: bold; color: #FF8F00; display: block; }
.sub { font-size: 24rpx; color: #B26A00; margin-top: 8rpx; display: block; }
.scroll { height: calc(100vh - 180rpx); padding: 0 24rpx; }
.summary { background: linear-gradient(135deg,#FFE082,#FFCC80); }
.summary-text { font-size: 28rpx; color: #6D4C00; line-height: 1.6; }
.section { margin-top: 24rpx; }
.course-card, .activity-card, .video-card { display: flex; align-items: center; }
.c-cover, .a-cover, .v-cover { width: 140rpx; height: 100rpx; border-radius: 12rpx; background: #FFE0B2; flex-shrink: 0; }
.c-info, .a-info, .v-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.c-title, .a-title, .v-title { font-size: 30rpx; font-weight: bold; }
.c-teacher, .a-time, .v-dur { font-size: 24rpx; margin: 8rpx 0; }
</style>
