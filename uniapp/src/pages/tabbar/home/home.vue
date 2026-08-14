<template>
  <view class="home">
    <view class="status-bar"></view>
    <!-- 顶部搜索 -->
    <view class="top">
      <view class="search" @click="goSearch">
        <text class="s-icon">🔍</text>
        <text class="s-text">搜索课程、活动、视频</text>
      </view>
    </view>

    <scroll-view scroll-y class="scroll" @refresherrefresh="onRefresh" :refresher-enabled="true" :refresher-triggered="refreshing">
      <!-- Banner 轮播（数据来自后台广告位 home_banner） -->
      <swiper class="banner" :indicator-dots="true" :autoplay="true" :interval="3500" :circular="true" indicator-color="rgba(255,255,255,.5)" indicator-active-color="#FFA000">
        <swiper-item v-for="(b, i) in banners" :key="i" @click="goBanner(b)">
          <image v-if="b.image" :src="b.image" mode="aspectFill" class="banner-img" />
          <view v-else class="banner-item" :style="{ background: b.bg }">
            <text class="b-emoji">{{ b.emoji }}</text>
            <text class="b-title">{{ b.title }}</text>
            <text class="b-sub">{{ b.sub }}</text>
          </view>
        </swiper-item>
      </swiper>

      <!-- 学习天地入口 -->
      <view class="grid">
        <view class="grid-item" v-for="g in categories" :key="g.id" @click="goArticle(g)">
          <view class="grid-icon" :style="{ background: g.bg }"><text>{{ g.emoji }}</text></view>
          <text class="grid-text">{{ g.name }}</text>
        </view>
      </view>

      <!-- 精选视频 横向滚动 -->
      <view class="section">
        <view class="section-title">精选视频</view>
        <scroll-view scroll-x class="h-scroll">
          <view class="video-card" v-for="v in videos" :key="v.id" @click="goVideo(v)">
            <view class="video-cover">
              <image :src="coverOf(v)" mode="aspectFill" class="cover-img" />
              <text class="play">▶</text>
            </view>
            <text class="video-title">{{ v.title }}</text>
          </view>
        </scroll-view>
      </view>

      <!-- 小宇宙计划 -->
      <view class="section">
        <view class="section-title">小宇宙计划</view>
        <view class="age-row">
          <view class="age-item" v-for="a in ages" :key="a.label" @click="goAge(a)">
            <view class="age-circle" :style="{ background: a.bg }">
              <text class="age-num">{{ a.num }}</text>
            </view>
            <text class="age-label">{{ a.label }}</text>
          </view>
        </view>
      </view>

      <!-- 优质店铺 -->
      <view class="section">
        <view class="section-title">优质店铺</view>
        <view class="card store-card" v-for="s in stores" :key="s.id" @click="goStore(s)">
          <image :src="coverOf(s)" mode="aspectFill" class="store-logo" />
          <view class="store-info">
            <text class="store-name">{{ s.name }}</text>
            <text class="store-intro text-muted">{{ s.intro || s.address || '优质儿童教育服务机构' }}</text>
            <text class="store-score">⭐ {{ s.score || '4.8' }}</text>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { videoApi, categoryApi, storeApi, adApi } from '../../../api/index.js'
import { coverOf } from '../../../config.js'

const banners = ref([])
const fallbackBanners = [
  { title: '优童成长计划', sub: '点亮孩子的每一个小宇宙', emoji: '🌟', bg: 'linear-gradient(135deg,#FFC107,#FF8F00)' },
  { title: '精品课程上线', sub: '名师陪伴，快乐学习', emoji: '📚', bg: 'linear-gradient(135deg,#FFD54F,#FFB300)' },
  { title: '周末亲子活动', sub: '一起探索世界的美好', emoji: '🎈', bg: 'linear-gradient(135deg,#FFE082,#FFA726)' }
]

const categories = ref([])
const videos = ref([])
const stores = ref([])
const ages = [
  { num: '0-3', label: '启蒙期', bg: '#FFE0B2', key: '0-3' },
  { num: '3-6', label: '幼龄段', bg: '#FFCC80', key: '3-6' },
  { num: '6-9', label: '学龄段', bg: '#FFB74D', key: '6-9' },
  { num: '9+', label: '成长段', bg: '#FFA726', key: '9+' }
]
const refreshing = ref(false)

async function loadData() {
  try {
    const [cat, vid, sto, ads] = await Promise.all([
      categoryApi.list({ page: 1, pageSize: 8 }),
      videoApi.list({ page: 1, pageSize: 6 }),
      storeApi.list({ page: 1, pageSize: 5 }),
      adApi.byPosition('home_banner')
    ])
    categories.value = (cat && cat.list && cat.list.length) ? cat.list.map(decorateCategory) : defaultCategories()
    videos.value = (vid && vid.list) ? vid.list : []
    stores.value = (sto && sto.list) ? sto.list : []
    banners.value = (ads && ads.length) ? ads : fallbackBanners
  } catch (e) {
    categories.value = defaultCategories()
    banners.value = fallbackBanners
  }
}

function defaultCategories() {
  return [
    { id: 1, name: '绘本阅读', emoji: '📖', bg: '#FFE0B2' },
    { id: 2, name: '益智游戏', emoji: '🧩', bg: '#FFCC80' },
    { id: 3, name: '科学启蒙', emoji: '🔬', bg: '#FFB74D' },
    { id: 4, name: '艺术创作', emoji: '🎨', bg: '#FFD54F' },
    { id: 5, name: '运动健康', emoji: '⚽', bg: '#FFB74D' },
    { id: 6, name: '音乐律动', emoji: '🎵', bg: '#FFE082' },
    { id: 7, name: '语言表达', emoji: '💬', bg: '#FFCC80' },
    { id: 8, name: '更多', emoji: '➕', bg: '#FFE0B2' }
  ]
}

const CATEGORY_ICONS = {
  '兴趣培养': { emoji: '🎨', bg: '#FFE0B2' },
  '学科辅导': { emoji: '📚', bg: '#FFCC80' },
  '绘画': { emoji: '🎨', bg: '#FFE0B2' },
  '音乐': { emoji: '🎵', bg: '#FFE082' },
  '数学': { emoji: '🧮', bg: '#FFB74D' },
  '英语': { emoji: '💬', bg: '#FFCC80' },
  '绘本阅读': { emoji: '📖', bg: '#FFE0B2' },
  '益智游戏': { emoji: '🧩', bg: '#FFCC80' },
  '科学启蒙': { emoji: '🔬', bg: '#FFB74D' },
  '艺术创作': { emoji: '🎨', bg: '#FFD54F' },
  '运动健康': { emoji: '⚽', bg: '#FFB74D' },
  '音乐律动': { emoji: '🎵', bg: '#FFE082' },
  '语言表达': { emoji: '💬', bg: '#FFCC80' }
}
function decorateCategory(c) {
  const icon = CATEGORY_ICONS[c.name] || { emoji: '⭐', bg: '#FFE0B2' }
  return { ...c, emoji: icon.emoji, bg: icon.bg }
}

function onRefresh() {
  refreshing.value = true
  loadData().finally(() => setTimeout(() => (refreshing.value = false), 600))
}
function goSearch() { uni.showToast({ title: '搜索功能开发中', icon: 'none' }) }
function goArticle(g) { uni.navigateTo({ url: '/pages/article/detail?id=' + (g.id || '') }) }
function goBanner(b) {
  if (!b || !b.url) return
  const url = b.url
  if (/^https?:/i.test(url)) {
    uni.setClipboardData({
      data: url,
      success: () => uni.showToast({ title: '链接已复制', icon: 'none' })
    })
    return
  }
  const page = bannerUrlToPage(url)
  if (page) {
    uni.navigateTo({ url: page })
  } else if (url.startsWith('/pages/')) {
    uni.navigateTo({ url })
  } else {
    uni.showToast({ title: '链接暂不可用', icon: 'none' })
  }
}

// 后台广告跳转链接形如 /course/2、/activity/1，需映射为小程序页面路径
function bannerUrlToPage(url) {
  const map = {
    course: '/pages/course/detail',
    activity: '/pages/activity/detail',
    video: '/pages/video/play',
    store: '/pages/store/detail',
    article: '/pages/article/detail'
  }
  const m = url.match(/^\/(course|activity|video|store|article)\/(\d+)\/?$/)
  return m ? `${map[m[1]]}?id=${m[2]}` : ''
}
function goVideo(v) { uni.navigateTo({ url: '/pages/video/play?id=' + v.id }) }
function goStore(s) { uni.navigateTo({ url: '/pages/store/detail?id=' + s.id }) }
function goAge(a) { uni.switchTab({ url: '/pages/tabbar/ai/ai' }) }

onMounted(loadData)
</script>

<style scoped>
.home { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 40rpx; position: fixed; top: 0; left: 0; right: 0; z-index: 100; background: #FFF8E1; }
.top { position: fixed; top: 40rpx; left: 0; right: 0; z-index: 100; padding: 4rpx 24rpx; background: #FFF8E1; }
.search { background: #fff; border-radius: 40rpx; height: 60rpx; display: flex; align-items: center; padding: 0 24rpx; box-shadow: 0 4rpx 16rpx rgba(255,160,0,.08); }
.s-icon { margin-right: 14rpx; }
.s-text { color: #bbb; font-size: 28rpx; }
.scroll { height: calc(100vh - 108rpx); margin-top: 108rpx; }
.banner { height: 300rpx; margin: 16rpx 24rpx; border-radius: 24rpx; overflow: hidden; }
.banner-item { height: 300rpx; display: flex; flex-direction: column; justify-content: center; padding: 40rpx; color: #fff; }
.banner-img { width: 100%; height: 100%; }
.b-emoji { font-size: 80rpx; }
.b-title { font-size: 40rpx; font-weight: bold; margin-top: 10rpx; }
.b-sub { font-size: 26rpx; margin-top: 8rpx; opacity: .9; }
.grid { display: flex; flex-wrap: wrap; padding: 0 12rpx; }
.grid-item { width: 25%; display: flex; flex-direction: column; align-items: center; padding: 16rpx 0; }
.grid-icon { width: 96rpx; height: 96rpx; border-radius: 28rpx; display: flex; align-items: center; justify-content: center; font-size: 48rpx; }
.grid-text { font-size: 24rpx; margin-top: 12rpx; color: #555; }
.section { padding: 0 24rpx; margin-top: 24rpx; }
.h-scroll { white-space: nowrap; }
.video-card { display: inline-block; width: 240rpx; margin-right: 20rpx; }
.video-cover { width: 240rpx; height: 160rpx; border-radius: 16rpx; overflow: hidden; position: relative; background: #FFE0B2; }
.cover-img { width: 100%; height: 100%; }
.play { position: absolute; right: 16rpx; bottom: 16rpx; width: 48rpx; height: 48rpx; border-radius: 50%; background: rgba(255,160,0,.85); color: #fff; font-size: 24rpx; text-align: center; line-height: 48rpx; }
.video-title { display: block; font-size: 26rpx; margin-top: 12rpx; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.age-row { display: flex; justify-content: space-between; padding: 0 12rpx; }
.age-item { display: flex; flex-direction: column; align-items: center; }
.age-circle { width: 110rpx; height: 110rpx; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.age-num { font-size: 30rpx; font-weight: bold; color: #fff; }
.age-label { font-size: 24rpx; margin-top: 12rpx; color: #555; }
.store-card { display: flex; align-items: center; }
.store-logo { width: 120rpx; height: 120rpx; border-radius: 16rpx; background: #FFE0B2; flex-shrink: 0; }
.store-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.store-name { font-size: 30rpx; font-weight: bold; }
.store-intro { font-size: 24rpx; margin: 8rpx 0; display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 1; overflow: hidden; }
.store-score { font-size: 24rpx; color: #FFA000; }
</style>
