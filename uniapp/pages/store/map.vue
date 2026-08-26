<template>
  <view class="map-page">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">优童门店地图导航</text>
      </view>
    </view>

    <!-- 定位降级友好提示条 -->
    <view class="degrade-tip" v-if="!locationSuccess">
      <text class="tip-text">⚠️ 暂未获取到定位，您可以手动在下方选择门店并导航</text>
      <text class="retry-btn" @click="fetchLocationAndStores">重试</text>
    </view>

    <!-- 地图核心视图 -->
    <view class="map-container">
      <map
        id="storeMap"
        class="main-map"
        :latitude="mapCenter.lat"
        :longitude="mapCenter.lng"
        :scale="mapScale"
        :markers="markers"
        :show-location="locationSuccess"
        @markertap="onMarkerTap"
      ></map>
    </view>

    <!-- 底部门店卡片滚动面板 -->
    <view class="bottom-panel">
      <view class="panel-header">
        <text class="panel-title">附近门店 (共 {{ storeList.length }} 家)</text>
        <text class="panel-sub" v-if="locationSuccess">已按距离由近及远排序</text>
      </view>

      <scroll-view scroll-x class="store-scroll" :show-scrollbar="false">
        <view class="store-card-list">
          <view
            class="store-card"
            v-for="s in storeList"
            :key="s.id"
            :class="{ active: currentStore && currentStore.id === s.id }"
            @click="selectStore(s)"
          >
            <view class="card-header">
              <text class="store-name">{{ s.name }}</text>
              <text class="store-score">⭐ {{ s.score || '4.9' }}</text>
            </view>

            <view class="card-body">
              <view class="info-row">
                <text class="i-icon">📍</text>
                <text class="i-text">{{ s.address || '地址信息详见详情' }}</text>
              </view>
              <view class="info-row" v-if="s.distanceText">
                <text class="i-icon">🚗</text>
                <text class="i-text text-primary">距离您：{{ s.distanceText }}</text>
              </view>
              <view class="info-row" v-if="s.businessHours">
                <text class="i-icon">🕐</text>
                <text class="i-text">{{ s.businessHours }}</text>
              </view>
            </view>

            <view class="card-actions">
              <button class="btn btn-detail" @click.stop="goDetail(s)">详情</button>
              <button class="btn btn-nav" @click.stop="openNav(s)">🧭 一键导航</button>
            </view>
          </view>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { storeApi } from '../../api/index.js'
import { getSafeUserLocation, calculateStoreDistance, openStoreNavigation } from '../../utils/storeMapHelper.js'

const storeList = ref([])
const currentStore = ref(null)
const markers = ref([])
const locationSuccess = ref(true)
const mapScale = ref(13)
const mapCenter = ref({ lat: 39.9042, lng: 116.4074 })
const userLocation = ref(null)

onMounted(() => {
  fetchLocationAndStores()
})

async function fetchLocationAndStores() {
  uni.showLoading({ title: '正在定位与加载门店...' })
  const loc = await getSafeUserLocation()
  locationSuccess.value = loc.success
  userLocation.value = { lat: loc.lat, lng: loc.lng }
  mapCenter.value = { lat: loc.lat, lng: loc.lng }

  try {
    const list = await storeApi.nearby({ lat: loc.lat, lng: loc.lng })
    const rows = Array.isArray(list) ? list : ((list && list.list) ? list.list : [])

    storeList.value = rows.map((s) => {
      const dist = loc.success && s.lat && s.lng
        ? calculateStoreDistance(loc.lat, loc.lng, s.lat, s.lng)
        : (s.distance ? `约 ${s.distance} 公里` : '')
      return {
        ...s,
        distanceText: dist
      }
    })

    buildMarkers()

    if (storeList.value.length > 0) {
      selectStore(storeList.value[0], false)
    }
  } catch (e) {
    console.error('获取门店列表失败:', e)
  } finally {
    uni.hideLoading()
  }
}

function buildMarkers() {
  markers.value = storeList.value.map((s, idx) => ({
    id: Number(s.id),
    latitude: Number(s.lat),
    longitude: Number(s.lng),
    title: s.name,
    width: 32,
    height: 32,
    callout: {
      content: `${s.name}\n${s.distanceText || ''}`,
      color: '#ffffff',
      fontSize: 12,
      borderRadius: 6,
      bgColor: '#FF8F00',
      padding: 6,
      display: 'BYCLICK'
    }
  }))
}

function selectStore(s, moveCenter = true) {
  currentStore.value = s
  if (moveCenter && s.lat && s.lng) {
    mapCenter.value = { lat: Number(s.lat), lng: Number(s.lng) }
    mapScale.value = 15
  }
}

function onMarkerTap(e) {
  const markerId = e.detail.markerId
  const found = storeList.value.find((s) => Number(s.id) === Number(markerId))
  if (found) {
    selectStore(found, true)
  }
}

function openNav(s) {
  openStoreNavigation(s)
}

function goDetail(s) {
  uni.navigateTo({ url: `/pages/store/detail?id=${s.id}` })
}

function goBack() {
  uni.navigateBack()
}
</script>

<style scoped>
.map-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: var(--c-bg-page);
}

.degrade-tip {
  background: #FFFBEB;
  border-bottom: 1rpx solid #FDE68A;
  padding: 12rpx var(--space-4);
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.tip-text { font-size: 22rpx; color: #B45309; flex: 1; }
.retry-btn { font-size: 22rpx; color: var(--c-info); font-weight: 700; margin-left: 16rpx; }

.map-container {
  flex: 1;
  width: 100%;
  position: relative;
}

.main-map {
  width: 100%;
  height: 100%;
}

.bottom-panel {
  background: #FFFFFF;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  padding: 20rpx 0 calc(20rpx + env(safe-area-inset-bottom));
  box-shadow: 0 -8rpx 24rpx rgba(0, 0, 0, 0.06);
  border-top: 1rpx solid var(--c-border);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 var(--space-4) 14rpx;
}
.panel-title { font-size: 30rpx; font-weight: 700; color: var(--c-text-title); }
.panel-sub { font-size: 22rpx; color: var(--c-text-muted); }

.store-scroll {
  width: 100%;
  white-space: nowrap;
}

.store-card-list {
  display: inline-flex;
  padding: 6rpx var(--space-3);
  gap: var(--space-3);
}

.store-card {
  width: 520rpx;
  background: #FAFBFC;
  border-radius: var(--radius-md);
  padding: var(--space-3);
  border: 2rpx solid var(--c-border);
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  white-space: normal;
  transition: all .2s;
}

.store-card.active {
  background: var(--c-primary-soft);
  border-color: var(--c-primary);
  box-shadow: var(--shadow-glow);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;
}
.store-name { font-size: 28rpx; font-weight: 700; color: var(--c-text-title); flex: 1; }
.store-score { font-size: 24rpx; color: var(--c-primary); font-weight: 700; }

.card-body { margin-bottom: 14rpx; }
.info-row { display: flex; align-items: center; margin-top: 6rpx; }
.i-icon { font-size: 22rpx; margin-right: 8rpx; }
.i-text { font-size: 22rpx; color: var(--c-text-main); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.text-primary { color: var(--c-primary); font-weight: 600; }

.card-actions {
  display: flex;
  gap: 12rpx;
  margin-top: auto;
}

.btn {
  flex: 1;
  height: 60rpx;
  line-height: 60rpx;
  border-radius: var(--radius-full);
  font-size: 24rpx;
  font-weight: 600;
  padding: 0;
}
.btn::after { border: none; }

.btn-detail { background: var(--c-bg-input); color: var(--c-text-main); border: 1rpx solid var(--c-border); }
.btn-nav { background: var(--c-primary-gradient); color: #FFFFFF; box-shadow: var(--shadow-glow); }
</style>
