<template>
  <view class="detail" v-if="course">
    <image :src="coverOf(course)" mode="aspectFill" class="banner" />
    <view class="body">
      <text class="title">{{ course.title }}</text>
      <view class="meta">
        <text class="price">¥{{ course.price || '0' }}</text>
        <text class="teacher text-muted">讲师：{{ course.teacher || '优童名师' }}</text>
      </view>
      <view class="tags">
        <text class="tag">🌟 精品课程</text>
        <text class="tag">👶 适龄教学</text>
        <text class="tag">🎓 结业证书</text>
      </view>
      <view class="section">
        <view class="section-title">课程介绍</view>
        <text class="intro text-muted">本课程由优童资深教研团队打磨，结合儿童成长发展规律，通过趣味互动帮助孩子轻松掌握知识，激发学习兴趣与创造力。</text>
      </view>
      <view class="section">
        <view class="section-title">课程亮点</view>
        <view class="point">📌 小班教学，关注每个孩子的进步</view>
        <view class="point">📌 情景化教学，寓教于乐</view>
        <view class="point">📌 阶段性测评，见证成长</view>
      </view>
    </view>

    <view class="bottom-bar">
      <button class="btn-primary signup-btn" @click="goSignup">立即报名</button>
    </view>
  </view>
  <view v-else class="loading">加载中...</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { courseApi } from '../../api/index.js'
import { coverOf } from '../../config.js'

const course = ref(null)
const id = ref('')

onMounted(() => {
  const pages = getCurrentPages()
  id.value = pages[pages.length - 1].options.id
  load()
})

async function load() {
  try {
    course.value = await courseApi.detail(id.value)
  } catch (e) {
    course.value = { id: id.value, title: '示例课程', price: '199', teacher: '优童名师' }
  }
}

function goSignup() {
  uni.navigateTo({ url: '/pages/course/signup?id=' + id.value })
}
</script>

<style scoped>
.detail { padding-bottom: 140rpx; }
.banner { width: 100%; height: 420rpx; background: #FFE0B2; }
.body { padding: 24rpx; }
.title { font-size: 40rpx; font-weight: bold; display: block; }
.meta { display: flex; align-items: center; justify-content: space-between; margin: 20rpx 0; }
.teacher { font-size: 26rpx; }
.tags { display: flex; flex-wrap: wrap; gap: 14rpx; margin-bottom: 10rpx; }
.tag { font-size: 24rpx; color: #FF8F00; background: #FFF3E0; border-radius: 20rpx; padding: 6rpx 18rpx; }
.section { margin-top: 30rpx; }
.intro { font-size: 28rpx; line-height: 1.7; }
.point { font-size: 28rpx; color: #555; margin: 12rpx 0; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; padding: 16rpx 24rpx; background: #fff; box-shadow: 0 -4rpx 16rpx rgba(0,0,0,.05); }
.signup-btn { width: 100%; }
.loading { text-align: center; padding: 120rpx 0; color: #999; }
</style>
