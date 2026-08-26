<template>
  <view class="store" v-if="store">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">店铺详情</text>
      </view>
    </view>
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
        <view class="info-row" v-if="distanceText">
          <text class="i-label">🚗 距离</text><text class="i-val">{{ distanceText }}</text>
        </view>
      </view>

      <!-- 店铺定位地图 -->
      <view class="section">
        <view class="section-header-row">
          <text class="section-title">店铺位置</text>
          <text class="map-link" @click="goToMap">🗺️ 查看所有门店地图 ›</text>
        </view>
        <view class="map-wrap">
          <map
            class="map"
            :latitude="Number(store.lat || 39.909)"
            :longitude="Number(store.lng || 116.397)"
            :markers="markers"
            :show-location="true"
            @markertap="onMarkerTap"
          ></map>
        </view>
        <button class="nav-btn" @click="openLocation">🧭 一键导航前往</button>
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
import { openStoreNavigation } from '../../utils/storeMapHelper.js'

const store = ref(null)
const courses = ref([])
const id = ref('')
const distanceText = ref('')
const markers = ref([])

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
  buildMarkers()
  getUserLocation()
}

// 根据店铺坐标生成地图标记
function buildMarkers() {
  const lat = Number(store.value?.lat)
  const lng = Number(store.value?.lng)
  if (!lat || !lng) return
  markers.value = [{
    id: 1,
    latitude: lat,
    longitude: lng,
    title: store.value.name || '店铺位置',
    width: 28,
    height: 28
  }]
}

// 获取用户当前位置，并计算与店铺的直线距离
function getUserLocation() {
  const lat = Number(store.value?.lat)
  const lng = Number(store.value?.lng)
  if (!lat || !lng) return
  uni.getLocation({
    type: 'gcj02',
    success: (res) => {
      const d = getDistance(res.latitude, res.longitude, lat, lng)
      distanceText.value = d < 1
        ? `约 ${Math.round(d * 1000)} 米`
        : `约 ${d.toFixed(1)} 公里`
    },
    fail: () => {
      // 用户拒绝授权或定位失败时不展示距离，不影响地图展示
      distanceText.value = ''
    }
  })
}

// 唤起外部地图进行导航
function openLocation() {
  openStoreNavigation(store.value)
}

function goToMap() {
  uni.navigateTo({ url: '/pages/store/map' })
}

// 点击地图标记同样唤起导航
function onMarkerTap() { openLocation() }

// 两个经纬度之间的直线距离（公里），使用 Haversine 公式
function getDistance(lat1, lng1, lat2, lng2) {
  const R = 6371
  const rad = (x) => (x * Math.PI) / 180
  const dLat = rad(lat2 - lat1)
  const dLng = rad(lng2 - lng1)
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLng / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

function goCourse(c) { uni.navigateTo({ url: '/pages/course/detail?id=' + c.id }) }
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.section-header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12rpx; }
.map-link { font-size: 24rpx; color: var(--c-primary); font-weight: 600; }
.store { min-height: 100vh; background-color: var(--c-bg-page); }
.banner {
  height: 280rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #fff;
  background: var(--c-primary-gradient) !important;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
  box-shadow: var(--shadow-glow);
}
.s-emoji { font-size: 80rpx; }
.s-name { font-size: 38rpx; font-weight: 700; margin-top: 8rpx; }
.s-score { font-size: 26rpx; margin-top: 8rpx; background: rgba(255,255,255,0.25); padding: 4rpx 20rpx; border-radius: var(--radius-full); }
.body { padding: var(--space-4); }
.card {
  background: #FFFFFF;
  border-radius: var(--radius);
  box-shadow: var(--shadow-card);
  padding: var(--space-3) var(--space-4);
  border: 1rpx solid var(--c-border);
}
.info-row { display: flex; align-items: center; padding: 16rpx 0; border-bottom: 1rpx solid var(--c-line); }
.info-row:last-child { border-bottom: none; }
.i-label { width: 150rpx; font-size: 26rpx; color: var(--c-text-muted); }
.i-val { flex: 1; font-size: 26rpx; color: var(--c-text-title); font-weight: 500; }
.section { margin-top: var(--space-4); }
.section-title { font-size: 30rpx; font-weight: 700; color: var(--c-text-title); }
.intro { font-size: 26rpx; line-height: 1.6; color: var(--c-text-main); }
.course-card { display: flex; align-items: center; background: #fff; border-radius: var(--radius); padding: var(--space-3); margin-bottom: var(--space-2); box-shadow: var(--shadow-card); border: 1rpx solid var(--c-border); }
.c-cover { width: 140rpx; height: 100rpx; border-radius: var(--radius-sm); background: var(--c-primary-soft); }
.c-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.c-title { font-size: 28rpx; font-weight: 700; color: var(--c-text-title); }
.price { font-size: 28rpx; color: var(--c-primary); font-weight: 700; margin-top: 6rpx; }
.loading { text-align: center; padding: 120rpx 0; color: var(--c-text-muted); }
.map-wrap { border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-card); border: 1rpx solid var(--c-border); margin-top: 12rpx; }
.map { width: 100%; height: 400rpx; }
.nav-btn { margin-top: 20rpx; background: var(--c-primary-gradient); color: #fff; border-radius: var(--radius-full); font-size: 30rpx; font-weight: 600; box-shadow: var(--shadow-glow); }
.nav-btn::after { border: none; }
</style>
