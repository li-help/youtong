<template>
  <view class="play">
    <view class="status-bar"></view>
    <view class="back-btn" @click.stop="goBack">
      <text class="back-icon">‹</text>
    </view>
    <view class="player" @click="onTogglePlay">
      <image :src="coverOf(video)" mode="aspectFill" class="poster" />
      <view v-if="showBtn" class="play-btn">
        <text class="play-icon">{{ playing ? '⏸' : '▶' }}</text>
      </view>
      <view class="bar">
        <view class="progress" :style="{ width: progress + '%' }"></view>
      </view>
      <text class="time">{{ currentTime }} / {{ durationText }}</text>
    </view>

    <view class="info">
      <text class="title">{{ video.title || '视频加载中...' }}</text>
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
import { ref, onMounted, onUnmounted } from 'vue'
import { videoApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const video = ref({})
const recommends = ref([])
const playing = ref(false)
const progress = ref(0)
const currentTime = ref('00:00')
const durationText = ref('00:00')
const showBtn = ref(true)
let timer = null

onMounted(() => {
  const pages = getCurrentPages()
  const id = pages[pages.length - 1].options.id
  load(id)
})

async function load(id) {
  try {
    video.value = await videoApi.detail(id)
  } catch (e) {
    video.value = { id, title: '示例视频', duration: 120 }
  }
  const d = video.value.duration || 120
  durationText.value = fmt(d)
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

function onTogglePlay() {
  if (playing.value) {
    // 播放中点击 -> 暂停并显示按钮
    pause()
  } else {
    // 暂停中点击 -> 继续播放并隐藏按钮
    play()
  }
}

function play() {
  playing.value = true
  showBtn.value = false
  let cur = 0
  const total = video.value.duration || 120
  timer = setInterval(() => {
    cur += 1
    progress.value = Math.min(100, (cur / total) * 100)
    currentTime.value = fmt(cur)
    if (cur >= total) {
      clearInterval(timer)
      timer = null
      playing.value = false
      showBtn.value = true
    }
  }, 1000)
}

function pause() {
  playing.value = false
  showBtn.value = true
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

function goVideo(v) {
  if (timer) clearInterval(timer)
  uni.redirectTo({ url: '/pages/video/play?id=' + v.id })
}

function goBack() {
  if (timer) clearInterval(timer)
  uni.navigateBack()
}

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.play { min-height: 100vh; background: #1a1a1a; }
.status-bar { height: var(--status-bar-height, 20rpx); }
.back-btn { position: absolute; top: calc(var(--status-bar-height, 20rpx) + 20rpx); left: 24rpx; z-index: 10; width: 64rpx; height: 64rpx; border-radius: 50%; background: rgba(0,0,0,.35); display: flex; align-items: center; justify-content: center; }
.back-icon { color: #fff; font-size: 48rpx; line-height: 1; margin-top: -4rpx; }
.player { position: relative; width: 100%; height: 460rpx; background: #000; display: flex; align-items: center; justify-content: center; }
.poster { width: 100%; height: 100%; opacity: .6; }
.play-btn { position: absolute; top: 120rpx; left: 50%; transform: translateX(-50%); width: 110rpx; height: 110rpx; border-radius: 50%; background: linear-gradient(135deg, #FFB300, #FF9F1C); display: flex; align-items: center; justify-content: center; box-shadow: 0 0 0 12rpx rgba(255, 159, 28, 0.28), 0 12rpx 32rpx rgba(255, 122, 0, 0.5); }
.play-icon { color: #fff; font-size: 48rpx; }
.bar { position: absolute; left: 0; right: 0; bottom: 20rpx; height: 8rpx; background: rgba(255,255,255,.3); margin: 0 30rpx; border-radius: 4rpx; }
.progress { height: 100%; background: #FFA000; border-radius: 4rpx; }
.time { position: absolute; right: 30rpx; bottom: 36rpx; color: #fff; font-size: 22rpx; }
.info { padding: 30rpx; }
.title { font-size: 36rpx; font-weight: bold; color: #fff; display: block; }
.section { margin-top: 30rpx; }
.section-title { color: #FFC107; font-size: 32rpx; font-weight: bold; margin-bottom: 16rpx; }
.section-title::before { background: #FFC107; }
.intro { color: #ccc; font-size: 28rpx; line-height: 1.7; }
.recommend { margin-top: 30rpx; }
.rec-card { display: flex; align-items: center; margin-bottom: 20rpx; }
.rec-cover { width: 200rpx; height: 130rpx; border-radius: 16rpx; background: #FFF3DE; }
.rec-title { color: #eee; font-size: 28rpx; margin-left: 20rpx; flex: 1; }
</style>
