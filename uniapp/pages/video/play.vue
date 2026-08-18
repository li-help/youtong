<template>
  <view class="play">
    <view class="status-bar"></view>
    <view class="back-btn" @click.stop="goBack">
      <text class="back-icon">‹</text>
    </view>
    <view class="player">
      <video
        v-if="videoUrl"
        :src="videoUrl"
        class="video"
        controls
        :poster="coverOf(video)"
        object-fit="contain"
        @error="onVideoError"
      ></video>
      <view v-else class="poster-box">
        <image :src="coverOf(video)" mode="aspectFill" class="poster" />
        <text class="no-url-tip">暂无视频源，请查看其他视频</text>
      </view>
    </view>

    <view class="info">
      <text class="title">{{ video.title || '视频加载中...' }}</text>
      <view class="meta">
        <text class="meta-item">时长：{{ durationText }}</text>
      </view>
      <view class="section">
        <view class="section-title">视频简介</view>
        <text class="intro text-muted">本视频由优童内容团队制作，画面温馨、节奏适中，适合儿童观看，帮助宝宝在轻松氛围中学习新知识。</text>
      </view>
      <view class="recommend">
        <view class="section-title">相关推荐</view>
        <view class="rec-card" v-for="v in recommends" :key="v.id" @click="goVideo(v)">
          <image :src="coverOf(v)" mode="aspectFill" class="rec-cover" />
          <text class="rec-title">{{ v.title }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { videoApi } from '../../api/index.js'
import { coverOf, resolveImg } from '../../config.js'

const video = ref({})
const recommends = ref([])
const durationText = ref('00:00')

const videoUrl = computed(() => resolveImg(video.value.url))

onMounted(() => {
  const pages = getCurrentPages()
  const id = pages[pages.length - 1].options.id
  load(id)
})

async function load(id) {
  try {
    video.value = await videoApi.detail(id)
  } catch (e) {
    video.value = { id, title: '视频加载失败' }
  }
  durationText.value = fmt(video.value.duration || 0)
  try {
    const r = await videoApi.list({ page: 1, pageSize: 4 })
    recommends.value = (r && r.list) ? r.list.filter(x => x.id != id).slice(0, 3) : []
  } catch (e) {}
}

function fmt(s) {
  s = Number(s) || 0
  const m = Math.floor(s / 60)
  const sec = s % 60
  return (m < 10 ? '0' + m : m) + ':' + (sec < 10 ? '0' + sec : sec)
}

function onVideoError() {
  uni.showToast({ title: '视频加载失败，请稍后重试', icon: 'none' })
}

function goVideo(v) {
  uni.redirectTo({ url: '/pages/video/play?id=' + v.id })
}

function goBack() {
  uni.navigateBack()
}
</script>

<style scoped>
.play { min-height: 100vh; background: #1a1a1a; }
.status-bar { height: var(--status-bar-height, 20rpx); }
.back-btn { position: absolute; top: calc(var(--status-bar-height, 20rpx) + 20rpx); left: 24rpx; z-index: 10; width: 64rpx; height: 64rpx; border-radius: 50%; background: rgba(0,0,0,.35); display: flex; align-items: center; justify-content: center; }
.back-icon { color: #fff; font-size: 48rpx; line-height: 1; margin-top: -4rpx; }
.player { position: relative; width: 100%; height: 460rpx; background: #000; display: flex; align-items: center; justify-content: center; }
.video { width: 100%; height: 100%; }
.poster-box { position: relative; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }
.poster { width: 100%; height: 100%; opacity: .6; }
.no-url-tip { position: absolute; bottom: 40rpx; color: #eee; font-size: 26rpx; background: rgba(0,0,0,.4); padding: 8rpx 24rpx; border-radius: 24rpx; }
.info { padding: 30rpx; }
.title { font-size: 36rpx; font-weight: bold; color: #fff; display: block; }
.meta { margin-top: 12rpx; }
.meta-item { color: #999; font-size: 24rpx; }
.section { margin-top: 30rpx; }
.section-title { color: #FFC107; font-size: 32rpx; font-weight: bold; margin-bottom: 16rpx; }
.intro { color: #ccc; font-size: 28rpx; line-height: 1.7; }
.recommend { margin-top: 30rpx; }
.rec-card { display: flex; align-items: center; margin-bottom: 20rpx; }
.rec-cover { width: 200rpx; height: 130rpx; border-radius: 16rpx; background: #FFF3DE; }
.rec-title { color: #eee; font-size: 28rpx; margin-left: 20rpx; flex: 1; }
</style>
