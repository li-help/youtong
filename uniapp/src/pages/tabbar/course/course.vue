<template>
  <view class="course">
    <view class="status-bar"></view>
    <view class="header">
      <text class="title">课程</text>
    </view>

    <scroll-view scroll-x class="cat-scroll">
      <view class="cat-item" :class="{ active: activeCat === '' }" @click="changeCat('')">全部</view>
      <view class="cat-item" v-for="c in cats" :key="c.id" :class="{ active: activeCat === c.id }" @click="changeCat(c.id)">{{ c.name }}</view>
    </scroll-view>

    <scroll-view scroll-y class="scroll" @refresherrefresh="onRefresh" :refresher-enabled="true" :refresher-triggered="refreshing">
      <view class="card course-card" v-for="c in list" :key="c.id" @click="goDetail(c)">
        <image :src="coverOf(c)" mode="aspectFill" class="c-cover" />
        <view class="c-info">
          <text class="c-title">{{ c.title }}</text>
          <text class="c-teacher text-muted">讲师：{{ c.teacher || '优童名师' }}</text>
          <view class="c-bottom">
            <text class="price">¥{{ c.price || '0' }}</text>
            <text class="c-tag">立即报名</text>
          </view>
        </view>
      </view>
      <view v-if="!list.length" class="empty">暂无课程数据</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { courseApi, categoryApi } from '../../../api/index.js'
import { coverOf } from '../../../config.js'

const cats = ref([])
const activeCat = ref('')
const list = ref([])
const refreshing = ref(false)

async function loadCats() {
  try {
    const r = await categoryApi.list({ page: 1, pageSize: 20 })
    cats.value = (r && r.list) ? r.list : []
  } catch (e) {}
}

async function loadList() {
  try {
    const r = await courseApi.list({ page: 1, pageSize: 20, categoryId: activeCat.value || undefined })
    list.value = (r && r.list) ? r.list : []
  } catch (e) {
    list.value = []
  }
}

function changeCat(id) {
  activeCat.value = id
  loadList()
}
function onRefresh() {
  refreshing.value = true
  loadList().finally(() => setTimeout(() => (refreshing.value = false), 500))
}
function goDetail(c) { uni.navigateTo({ url: '/pages/course/detail?id=' + c.id }) }

onMounted(() => { loadCats(); loadList() })
</script>

<style scoped>
.course { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { padding: 20rpx 24rpx; }
.title { font-size: 40rpx; font-weight: bold; color: #FF8F00; }
.cat-scroll { white-space: nowrap; padding: 0 24rpx 16rpx; }
.cat-item { display: inline-block; padding: 12rpx 30rpx; background: #fff; border-radius: 40rpx; margin-right: 16rpx; font-size: 26rpx; color: #777; }
.cat-item.active { background: linear-gradient(90deg, #FFC107, #FFA000); color: #fff; }
.scroll { height: calc(100vh - 280rpx); padding: 0 24rpx; }
.course-card { display: flex; align-items: center; }
.c-cover { width: 200rpx; height: 150rpx; border-radius: 16rpx; background: #FFE0B2; flex-shrink: 0; }
.c-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.c-title { font-size: 30rpx; font-weight: bold; }
.c-teacher { font-size: 24rpx; margin: 10rpx 0; }
.c-bottom { display: flex; align-items: center; justify-content: space-between; margin-top: 10rpx; }
.c-tag { font-size: 24rpx; color: #FFA000; border: 2rpx solid #FFA000; border-radius: 30rpx; padding: 4rpx 18rpx; }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
