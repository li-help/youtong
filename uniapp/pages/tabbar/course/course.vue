<template>
  <view class="course">
    <!-- 白色顶栏 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">课程</text>
      </view>
    </view>

    <!-- 搜索栏（独立一行） -->
    <view class="search-row">
      <view class="search-box" @click="onSearch">
        <text class="search-ic">🔍</text>
        <input class="search-input" v-model="kw" placeholder="搜索课程、兴趣、老师" placeholder-class="ph" @confirm="onSearch" />
      </view>
    </view>

    <scroll-view scroll-y class="scroll">

      <!-- 分类网格 -->
      <view class="cate-section">
        <view class="cate-grid">
          <view class="cate-item" :class="{ active: curCate === '' }" @click="selectCate('')">
            <view class="tile" :style="{ background: 'linear-gradient(145deg,#FFF4E0,#FFE8B8)' }">
              <text class="tile__emoji">📚</text>
            </view>
            <text class="cate-text">全部</text>
          </view>
          <view class="cate-item" v-for="c in categories" :key="c.id" :class="{ active: curCate === c.id }" @click="selectCate(c.id)">
            <view class="tile" :style="{ background: c.bg }">
              <text class="tile__emoji">{{ c.emoji }}</text>
            </view>
            <text class="cate-text">{{ c.name }}</text>
          </view>
        </view>
      </view>

      <!-- 热销课程 -->
      <view class="hot-section">
        <view class="section-head">
          <text class="section-head__title">热销课程</text>
          <text class="section-head__more">为你精选 ›</text>
        </view>

        <view class="course-card" v-for="(item, i) in list" :key="item.id" @click="goDetail(item)">
          <view class="course-cover-wrap">
            <image :src="coverOf(item)" mode="aspectFill" class="course-cover" />
            <view v-if="i === 0" class="hot-tag">🔥 热销</view>
          </view>
          <view class="course-info">
            <text class="course-name">{{ item.title }}</text>
            <text class="course-desc">{{ item.subtitle || item.summary || '优质课程' }}</text>
            <view class="course-meta">
              <text class="course-price">¥{{ item.price }}</text>
              <text class="course-count">{{ item.studentCount || item.sold || 0 }}人已学</text>
            </view>
          </view>
        </view>
        
        <view v-if="!list.length" class="empty">
          <text>暂无课程～</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { onShow, onHide } from '@dcloudio/uni-app'
import { courseApi, categoryApi } from '../../../api/index.js'
import { coverOf } from '../../../config.js'
import { useRealtime } from '../../../utils/realtime.js'

const kw = ref('')
const curCate = ref('')
const list = ref([])
const categories = ref([])

const CATEGORY_ICONS = {
  '兴趣培养': '🎨', '学科辅导': '📚', '绘画': '🎨', '音乐': '🎵', '数学': '🧮',
  '英语': '💬', '绘本阅读': '📖', '益智游戏': '🧩', '科学启蒙': '🔬', '艺术创作': '🎨',
  '运动健康': '⚽', '音乐律动': '🎵', '语言表达': '💬'
}
const CATEGORY_BG = [
  'linear-gradient(145deg,#FFE3C2,#FFC98A)',
  'linear-gradient(145deg,#FDE2EC,#FBB9CF)',
  'linear-gradient(145deg,#E3F2FD,#B9E3FA)',
  'linear-gradient(145deg,#E8F5E9,#C4E8C6)',
  'linear-gradient(145deg,#F3E5F5,#E0BBE4)',
  'linear-gradient(145deg,#FFF8E1,#FFEDB3)',
  'linear-gradient(145deg,#E0F7FA,#A7E8F0)',
  'linear-gradient(145deg,#FFE0E0,#FFB3B3)'
]
function decorateCategory(c, i) {
  return { ...c, emoji: CATEGORY_ICONS[c.name] || '⭐', bg: CATEGORY_BG[(i || 0) % CATEGORY_BG.length] }
}

async function loadCategories() {
  try {
    const res = await categoryApi.list({ page: 1, pageSize: 12 })
    categories.value = (res && res.list) ? res.list.map((c, i) => decorateCategory(c, i)) : []
  } catch (e) {
    categories.value = []
  }
}

async function loadList() {
  try {
    const params = { page: 1, pageSize: 20 }
    if (kw.value) params.keyword = kw.value
    if (curCate.value) params.categoryId = curCate.value
    const res = await courseApi.list(params)
    list.value = (res && res.list) ? res.list : []
  } catch (e) {
    list.value = []
  }
}

function selectCate(id) {
  curCate.value = id
  loadList()
}
function onSearch() {
  loadList()
}
function goDetail(item) {
  uni.navigateTo({ url: '/pages/course/detail?id=' + item.id })
}

// 后台课程或分类变更时实时刷新
const realtime = useRealtime('course', loadList)
const realtimeCat = useRealtime('category', loadCategories)

onMounted(() => {
  loadCategories()
  loadList()
})
onShow(() => {
  realtime.start()
  realtimeCat.start()
})
onHide(() => {
  realtime.stop()
  realtimeCat.stop()
})
</script>

<style scoped>
.course { min-height: 100vh; background: #F5F6FA; }

/* 搜索栏 */
.search-row {
  padding: 20rpx 32rpx;
  background: #fff;
}
.search-box {
  display: flex; align-items: center;
  background: #F5F6FA;
  border-radius: 40rpx;
  padding: 18rpx 28rpx;
}
.search-ic { font-size: 28rpx; margin-right: 12rpx; }
.search-input { flex: 1; font-size: 28rpx; color: #2D2D2D; }
.ph { color: #bbb; }

.scroll { height: calc(100vh - 88rpx - 76rpx); }

/* 分类网格 */
.cate-section { padding: 32rpx 32rpx 24rpx; }
.cate-grid { display: flex; flex-wrap: wrap; gap: 24rpx; }
.cate-item { width: calc(25% - 18rpx); display: flex; flex-direction: column; align-items: center; }
.tile {
  width: 100rpx; height: 100rpx; border-radius: 24rpx;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,.06);
  transition: transform .15s;
}
.tile__emoji { font-size: 48rpx; }
.cate-item.active .tile {
  box-shadow: 0 0 0 5rpx rgba(246,181,30,.3);
  transform: scale(1.06);
}
.cate-text { font-size: 24rpx; color: #777; margin-top: 14rpx; }
.cate-item.active .cate-text { color: #E89B00; font-weight: bold; }

/* 热销课程 */
.hot-section { padding: 8rpx 32rpx; }

.course-card {
  display: flex;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,.04);
}
.course-cover-wrap { position: relative; flex-shrink: 0; }
.course-cover { width: 220rpx; height: 160rpx; border-radius: 16rpx; background: #EEEFF3; flex-shrink: 0; }
.hot-tag {
  position: absolute; top: 10rpx; left: 10rpx;
  font-size: 20rpx; color: #fff;
  background: linear-gradient(135deg, #FF6B4A, #FF3D3D);
  padding: 4rpx 14rpx; border-radius: 20rpx;
  box-shadow: 0 4rpx 12rpx rgba(255,61,61,.3);
}
.course-info {
  flex: 1; margin-left: 24rpx;
  display: flex; flex-direction: column; justify-content: space-between;
  padding: 4rpx 0;
}
.course-name { font-size: 30rpx; font-weight: bold; color: #2D2D2D; display: block; }
.course-desc {
  font-size: 24rpx; color: #999; margin-top: 8rpx;
  display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden;
}
.course-meta { display: flex; align-items: center; justify-content: space-between; margin-top: 12rpx; }
.course-price { font-size: 34rpx; font-weight: bold; color: #FF7043; }
.course-count { font-size: 22rpx; color: #bbb; }

.empty { text-align: center; padding: 80rpx 0; color: #bbb; font-size: 28rpx; }
.bottom-space { height: 40rpx; }
</style>
