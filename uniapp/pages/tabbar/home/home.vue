<template>
  <view class="home">
    <!-- 顶部标题 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">优童成长</text>
      </view>
    </view>

    <scroll-view scroll-y class="scroll" @refresherrefresh="onRefresh" :refresher-enabled="true" :refresher-triggered="refreshing">
      <!-- Banner 轮播 -->
      <swiper class="banner" :indicator-dots="true" :autoplay="true" :interval="3500" :circular="true" indicator-color="rgba(255,255,255,.5)" indicator-active-color="#FFA000">
        <swiper-item v-for="(b, i) in banners" :key="i" @click="goBanner(b)">
          <image v-if="b.image" :src="resolveImg(b.image)" mode="aspectFill" class="banner-img" />
          <view v-else class="banner-item" :style="{ background: b.bg }">
            <text class="b-deco deco-1">⭐</text>
            <text class="b-deco deco-2">🎈</text>
            <text class="b-deco deco-3">✨</text>
            <text class="b-emoji">{{ b.emoji }}</text>
            <text class="b-title">{{ b.title }}</text>
            <text class="b-sub">{{ b.sub }}</text>
          </view>
        </swiper-item>
      </swiper>

      <!-- 学习天地入口 -->
      <view class="section">
        <view class="section-header">
          <view class="section-icon">🎯</view>
          <text class="section-title">学习天地</text>
          <view class="deco-star-small">⭐</view>
        </view>
        <view class="grid">
          <view class="grid-item" v-for="g in categories" :key="g.id" @click="goArticle(g)">
            <view class="tile" :style="{ background: g.bg }">
              <text class="tile__emoji">{{ g.emoji }}</text>
            </view>
            <text class="grid-text">{{ g.name }}</text>
          </view>
        </view>
      </view>

      <!-- 精选视频 -->
      <view class="section">
        <view class="section-header">
          <view class="section-icon">📦</view>
          <text class="section-title">精选视频</text>
          <view class="deco-star-small">⭐</view>
        </view>
        <scroll-view scroll-x class="h-scroll">
          <view class="video-card" v-for="v in videos" :key="v.id" @click="goVideo(v)">
            <view class="video-cover">
              <image :src="coverOf(v)" mode="aspectFill" class="cover-img" />
              <view class="cover-mask"></view>
              <view class="play-btn">▶</view>
            </view>
            <text class="video-name">{{ v.title }}</text>
          </view>
        </scroll-view>
      </view>

      <!-- 小宇宙计划 -->
      <view class="section">
        <view class="plan-card">
          <text class="plan-deco">🚀</text>
          <view class="plan-header">
            <view class="plan-left">
              <text class="plan-title">小宇宙计划</text>
              <text class="plan-desc">养育宝宝学习<br />发现兴趣与方向</text>
            </view>
            <view class="plan-right">
              <text class="plan-more">查看更多 ›</text>
            </view>
          </view>
          
          <!-- 年龄选择 -->
          <view class="age-row">
            <view class="age-tag hot">🔥 热门</view>
            <view class="age-tag" v-for="a in ages" :key="a.key">{{ a.label }}</view>
          </view>
          
          <button class="btn-plan" @click="goPlan">了解详情</button>
        </view>
      </view>

      <!-- 优质店铺 -->
      <view class="section">
        <view class="section-header-row">
          <view class="section-icon">🏪</view>
          <text class="section-title">优质店铺</text>
          <text class="more-link" @click="goMoreStore">查看更多 ›</text>
        </view>
        
        <view class="store-grid">
          <view class="store-item" v-for="s in stores" :key="s.id" @click="goStore(s)">
            <image :src="coverOf(s)" mode="aspectFill" class="store-logo" />
            <text class="store-name">{{ s.name }}</text>
            <view class="store-score-row">
              <text class="store-score">{{ s.score || '4.8' }} ⭐</text>
            </view>
            <view class="store-badge">👑 宝宝解锁</view>
          </view>
        </view>
      </view>

      <!-- 底部间距 -->
      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { onShow, onHide, onUnload } from '@dcloudio/uni-app'
import { videoApi, categoryApi, storeApi, bannerApi } from '../../../api/index.js'
import { coverOf, resolveImg } from '../../../config.js'

const banners = ref([])
const fallbackBanners = [
  { title: '优童成长', sub: '陪伴每一个成长的小宇宙', emoji: '💃', bg: 'linear-gradient(135deg,#FFF8E1,#FFECB3)' },
  { title: '精品课程', sub: '名师陪伴 快乐学习', emoji: '📚', bg: 'linear-gradient(135deg,#FFECB3,#FFE0B2)' },
  { title: '亲子活动', sub: '一起探索世界的美好', emoji: '🎈', bg: 'linear-gradient(135deg,#FFE0B2,#FFD54F)' }
]

const categories = ref([])
const videos = ref([])
const stores = ref([])
const ages = [
  { label: '1-2岁', key: '1-2' },
  { label: '3-4岁', key: '3-4' },
  { label: '4-5岁', key: '4-5' },
  { label: '5-6岁', key: '5-6' }
]
const refreshing = ref(false)

async function loadData() {
  try {
    const [cat, vid, sto, ads] = await Promise.all([
      categoryApi.list({ page: 1, pageSize: 8 }),
      videoApi.list({ page: 1, pageSize: 6 }),
      storeApi.list({ page: 1, pageSize: 8 }),
      bannerApi.home('home_banner')
    ])
    categories.value = (cat && cat.list && cat.list.length) ? cat.list.map(decorateCategory) : defaultCategories()
    videos.value = (vid && vid.list) ? vid.list : []
    stores.value = (sto && sto.list) ? sto.list : []
    banners.value = (ads && ads.length) ? ads : fallbackBanners
    lastVersion.value = ads ? await bannerApi.version().catch(() => lastVersion.value) : lastVersion.value
  } catch (e) {
    categories.value = defaultCategories()
    banners.value = fallbackBanners
  }
}

// ===== 后台数据实时响应（轮询版本号 + H5 端 SSE 推送）=====
import { useRealtime } from '../../../utils/realtime.js'

// 后台广告/课程/视频/门店等任一频道变更，均刷新对应区块
const realtime = useRealtime('banner', async () => {
  try {
    const ads = await bannerApi.home('home_banner')
    banners.value = (ads && ads.length) ? ads : fallbackBanners
  } catch (e) { /* 静默失败，下次轮询/推送再试 */ }
})

function defaultCategories() {
  return [
    { id: 1, name: '视频课程', emoji: '📺', bg: '#E3F2FD' },
    { id: 2, name: '创意绘画', emoji: '🎨', bg: '#FCE4EC' },
    { id: 3, name: '音乐启蒙', emoji: '🎵', bg: '#FFF8E1' },
    { id: 4, name: '益智游戏', emoji: '🧩', bg: '#E8F5E9' }
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
  '语言表达': { emoji: '💬', bg: '#FFCC80' },
  '视频课程': { emoji: '📺', bg: '#E3F2FD' },
  '创意绘画': { emoji: '🎨', bg: '#FCE4EC' }
}
function decorateCategory(c) {
  const icon = CATEGORY_ICONS[c.name] || { emoji: '⭐', bg: '#FFE0B2' }
  return { ...c, emoji: icon.emoji, bg: icon.bg }
}

function onRefresh() {
  refreshing.value = true
  loadData().finally(() => setTimeout(() => (refreshing.value = false), 600))
}
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
function bannerUrlToPage(url) {
  const map = {
    course: '/pages/course/detail',
    activity: '/pages/activity/detail',
    video: '/pages/video/play',
    store: '/pages/store/detail',
    article: '/pages/article/detail',
    service: '/pages/service/list'
  }
  const m = url.match(/^\/(course|activity|video|store|article|service)\/(\d+)\/?$/)
  return m ? `${map[m[1]]}?id=${m[2]}` : ''
}
function goVideo(v) { uni.navigateTo({ url: '/pages/video/play?id=' + v.id }) }
function goStore(s) { uni.navigateTo({ url: '/pages/store/detail?id=' + s.id }) }
function goPlan() { uni.switchTab({ url: '/pages/tabbar/ai/ai' }) }
function goMoreStore() { uni.showToast({ title: '查看更多店铺', icon: 'none' }) }

// 进入页面：拉取数据并开启实时监听（轮询兜底 + H5 SSE 推送）
onMounted(() => {
  loadData()
  realtime.start()
})
// 切回前台时确保监听在运行（防御性重启）
onShow(() => {
  realtime.start()
})
// 离开页面/隐藏时关闭监听，避免无效请求与连接泄漏
onHide(() => {
  realtime.stop()
})
onUnload(() => {
  realtime.stop()
})
</script>

<style scoped>
.home { min-height: 100vh; background: #F5F6FA; }
.scroll { height: calc(100vh - 88rpx); }

/* Banner */
.banner { height: 320rpx; margin: 24rpx 32rpx 0; border-radius: 24rpx; overflow: hidden; box-shadow: 0 8rpx 28rpx rgba(0,0,0,.08); }
.banner-item { height: 320rpx; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 40rpx; color: #888; position: relative; overflow: hidden; background: linear-gradient(135deg,#FFF4E0,#FFE8B8); }
.banner-img { width: 100%; height: 100%; border-radius: 24rpx; }
.b-emoji { font-size: 80rpx; }
.b-title { font-size: 38rpx; font-weight: bold; color: #2D2D2D; margin-top: 12rpx; }
.b-sub { font-size: 26rpx; color: #999; margin-top: 8rpx; }
.b-deco { position: absolute; opacity: 0.35; }
.deco-1 { top: 30rpx; left: 44rpx; font-size: 50rpx; transform: rotate(-14deg); }
.deco-2 { top: 64rpx; right: 52rpx; font-size: 46rpx; transform: rotate(16deg); }
.deco-3 { bottom: 40rpx; left: 64rpx; font-size: 36rpx; transform: rotate(8deg); }

/* Section通用 */
.section { padding: 0 32rpx; margin-top: 40rpx; }
.section-header { display: flex; align-items: center; margin-bottom: 24rpx; }
.section-icon { font-size: 32rpx; margin-right: 10rpx; }
.section-title { font-size: 34rpx; font-weight: bold; color: #2D2D2D; position: relative; padding-left: 24rpx; }
.section-title::before { content: ''; position: absolute; left: 0; top: 50%; transform: translateY(-50%); width: 8rpx; height: 32rpx; border-radius: 4rpx; background: linear-gradient(180deg, #FF9F2E, #F6B51E); }
.deco-star-small { font-size: 24rpx; margin-left: auto; opacity: 0.35; }
.section-header-row { display: flex; align-items: center; margin-bottom: 24rpx; }
.more-link { font-size: 26rpx; color: #E89B00; margin-left: auto; }

/* 学习天地网格 */
.grid { display: flex; flex-wrap: wrap; gap: 24rpx; }
.grid-item { width: calc(25% - 18rpx); display: flex; flex-direction: column; align-items: center; }
.tile {
  width: 100rpx; height: 100rpx; border-radius: 24rpx;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,.06);
}
.tile__emoji { font-size: 48rpx; }
.grid-text { font-size: 24rpx; color: #777; margin-top: 14rpx; }

/* 精选视频 */
.h-scroll { white-space: nowrap; }
.video-card { display: inline-block; width: 240rpx; margin-right: 24rpx; vertical-align: top; }
.video-cover { width: 240rpx; height: 160rpx; border-radius: 20rpx; overflow: hidden; position: relative; background: #eee; box-shadow: 0 8rpx 24rpx rgba(0,0,0,.08); }
.cover-img { width: 100%; height: 100%; }
.cover-mask { position: absolute; left: 0; right: 0; bottom: 0; height: 70%; background: linear-gradient(180deg, transparent, rgba(0,0,0,.30)); }
.play-btn {
  position: absolute; left: 50%; top: 50%; transform: translate(-50%,-50%);
  width: 60rpx; height: 60rpx; border-radius: 50%;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  color: #fff; font-size: 24rpx;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 0 0 8rpx rgba(246,181,30,.22);
}
.video-name {
  display: block; font-size: 26rpx; color: #2D2D2D; margin-top: 14rpx;
  line-height: 1.4; white-space: normal;
  display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden;
}

/* 小宇宙计划 */
.plan-card {
  position: relative;
  background: linear-gradient(135deg, #FFB300, #FF7A00);
  border-radius: 28rpx;
  padding: 36rpx 32rpx;
  overflow: hidden;
  box-shadow: 0 12rpx 36rpx rgba(255,122,0,.25);
  color: #fff;
}
.plan-deco { position: absolute; right: -12rpx; top: -8rpx; font-size: 160rpx; opacity: .18; transform: rotate(15deg); }
.plan-header { display: flex; justify-content: space-between; align-items: flex-start; position: relative; }
.plan-title { font-size: 34rpx; font-weight: bold; color: #fff; display: block; }
.plan-desc { font-size: 24rpx; color: rgba(255,255,255,.85); margin-top: 10rpx; line-height: 1.6; }
.plan-more { font-size: 24rpx; color: rgba(255,255,255,.90); }
.age-row { display: flex; gap: 12rpx; margin: 24rpx 0; flex-wrap: wrap; }
.age-tag {
  padding: 10rpx 26rpx;
  border-radius: 30rpx;
  background: rgba(255,255,255,.22);
  font-size: 24rpx; color: #fff;
  border: 2rpx solid rgba(255,255,255,.35);
}
.age-tag.hot { background: #fff; color: #E89B00; border-color: transparent; font-weight: bold; }
.btn-plan {
  width: 220rpx; height: 64rpx; line-height: 64rpx;
  background: #fff; border-radius: 32rpx;
  font-size: 28rpx; font-weight: 600; color: #E89B00;
  border: none; margin-top: 6rpx;
  box-shadow: 0 6rpx 20rpx rgba(0,0,0,.10);
}

/* 优质店铺 */
.store-grid { display: flex; flex-wrap: wrap; gap: 24rpx; }
.store-item {
  width: calc(50% - 12rpx);
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,.04);
}
.store-logo { width: 100%; height: 190rpx; border-radius: 16rpx; background: #EEEFF3; }
.store-name { display: block; font-size: 28rpx; font-weight: bold; color: #2D2D2D; margin-top: 16rpx; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.store-score-row { margin-top: 10rpx; }
.store-score { font-size: 24rpx; color: #F6B51E; font-weight: 600; }
.store-badge {
  display: inline-block; font-size: 20rpx; color: #fff;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  padding: 4rpx 14rpx; border-radius: 20rpx; margin-top: 10rpx;
}

.bottom-space { height: 40rpx; }
</style>
