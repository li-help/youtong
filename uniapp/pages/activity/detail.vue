<template>
  <view class="detail" v-if="activity">
    <AppNav title="活动详情" back>
      <template #right>
        <text class="nav-fav" @click="toggleFav">{{ fav ? '★' : '☆' }}</text>
      </template>
    </AppNav>
    <image :src="coverOf(activity)" mode="aspectFill" class="banner" />
    <view class="body">
      <text class="title">{{ activity.title }}</text>
      <view class="meta">
        <text class="m-item">🕐 {{ activity.startTime || '时间待定' }}</text>
        <text class="m-item">📍 {{ activity.address || '优童活动中心' }}</text>
      </view>
      <view class="section">
        <text class="section-head__title">活动详情</text>
        <text class="intro text-muted">本活动由优童精心策划，邀请家庭共同参与，在专业老师引导下通过游戏、手工、互动体验等方式，增进亲子感情，促进孩子综合能力发展。</text>
      </view>
      <view class="section">
        <text class="section-head__title">活动流程</text>
        <view class="point">📌 签到入场 & 破冰互动</view>
        <view class="point">📌 主题游戏 & 亲子协作</view>
        <view class="point">📌 作品展示 & 合影留念</view>
      </view>
    </view>
    <view class="bottom-bar">
      <button class="btn-primary signup-btn" @click="openJoin">报名参加</button>
    </view>

    <!-- 报名弹窗 -->
    <view v-if="showJoin" class="join-mask" @click.self="showJoin = false">
      <view class="join-modal">
        <text class="join-title">活动报名</text>
        <text class="join-name">{{ activity.title }}</text>
        <input class="join-input" v-model="joinForm.contactName" placeholder="联系人姓名" placeholder-class="ph" />
        <input class="join-input" v-model="joinForm.contactPhone" type="number" maxlength="11" placeholder="联系人手机号" placeholder-class="ph" />
        <button class="btn-confirm" :loading="joining" @click="submitJoin">确认报名</button>
        <text class="join-close" @click="showJoin = false">取消</text>
      </view>
    </view>
  </view>
  <view v-else class="loading">加载中...</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { activityApi, orderApi, favoriteApi } from '../../api/index.js'
import { coverOf } from '../../config.js'
import { userStore } from '../../store/user.js'
import AppNav from '../../components/AppNav.vue'

const activity = ref(null)
const id = ref('')
const showJoin = ref(false)
const joining = ref(false)
const fav = ref(false)
const joinForm = reactive({ contactName: '', contactPhone: '' })

onMounted(() => {
  const pages = getCurrentPages()
  id.value = pages[pages.length - 1].options.id
  load()
  checkFav()
})

async function checkFav() {
  if (!userStore.token || !id.value) return
  try {
    const r = await favoriteApi.status('activity', id.value)
    fav.value = !!r
  } catch (e) { /* 忽略 */ }
}

async function toggleFav() {
  if (!userStore.token) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  try {
    if (fav.value) {
      await favoriteApi.remove({ targetType: 'activity', targetId: id.value })
      fav.value = false
      uni.showToast({ title: '已取消收藏', icon: 'none' })
    } else {
      await favoriteApi.add({
        targetType: 'activity',
        targetId: id.value,
        title: activity.value && activity.value.title ? activity.value.title : '活动',
        cover: activity.value ? coverOf(activity.value) : ''
      })
      fav.value = true
      uni.showToast({ title: '已收藏', icon: 'success' })
    }
  } catch (e) {
    uni.showToast({ title: '操作失败，请稍后重试', icon: 'none' })
  }
}

async function load() {
  try {
    activity.value = await activityApi.detail(id.value)
  } catch (e) {
    activity.value = { id: id.value, title: '活动加载失败', address: '优童活动中心' }
  }
}

function openJoin() {
  joinForm.contactName = ''
  joinForm.contactPhone = ''
  showJoin.value = true
}

async function submitJoin() {
  if (!joinForm.contactName) {
    uni.showToast({ title: '请输入联系人姓名', icon: 'none' })
    return
  }
  if (!/^1[3-9]\d{9}$/.test(joinForm.contactPhone)) {
    uni.showToast({ title: '请输入有效的手机号', icon: 'none' })
    return
  }
  joining.value = true
  try {
    await orderApi.create({
      courseName: activity.value.title,
      price: 0,
      contactName: joinForm.contactName,
      contactPhone: joinForm.contactPhone,
      remark: '活动报名'
    })
    uni.showToast({ title: '报名成功，请准时参加', icon: 'success' })
    showJoin.value = false
  } catch (e) {
    // 错误提示已由 request 统一处理
  } finally {
    joining.value = false
  }
}

function goBack() { uni.navigateBack() }
</script>

<style scoped>
.detail { padding-bottom: 150rpx; background: var(--c-bg); min-height: 100vh; }
.banner { width: 100%; height: 380rpx; background: var(--c-bg-warm); }
.body { padding: var(--pad); }
.title { font-size: 40rpx; font-weight: bold; display: block; color: var(--c-text); }
.meta { display: flex; flex-direction: column; margin: 24rpx 0; background: #fff; border-radius: var(--radius); padding: 24rpx 32rpx; box-shadow: var(--shadow-card); }
.m-item { font-size: 26rpx; color: var(--c-text-2); margin: 8rpx 0; }
.section { margin-top: 36rpx; }
.intro { font-size: 28rpx; line-height: 1.7; color: var(--c-text-2); }
.point { font-size: 28rpx; color: var(--c-text-2); margin: 14rpx 0; }
.nav-fav { margin-left: auto; font-size: 44rpx; color: var(--c-primary-light); line-height: 88rpx; padding-right: 8rpx; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; padding: 18rpx 32rpx; padding-bottom: calc(18rpx + env(safe-area-inset-bottom)); background: #fff; box-shadow: 0 -6rpx 24rpx rgba(0,0,0,.06); }
.signup-btn { width: 100%; }
.loading { text-align: center; padding: 120rpx 0; color: var(--c-text-3); }
.join-mask { position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 999; display: flex; align-items: center; justify-content: center; }
.join-modal { width: 600rpx; background: #fff; border-radius: var(--radius); padding: 40rpx; display: flex; flex-direction: column; align-items: center; }
.join-title { font-size: 34rpx; font-weight: bold; color: var(--c-text); margin-bottom: 12rpx; }
.join-name { font-size: 26rpx; color: var(--c-text-2); margin-bottom: 30rpx; }
.join-input { width: 100%; background: var(--c-bg); border: 2rpx solid var(--c-line); border-radius: 16rpx; padding: 22rpx 26rpx; margin-bottom: 20rpx; font-size: 28rpx; }
.ph { color: var(--c-text-3); }
.btn-confirm { width: 100%; height: 88rpx; line-height: 88rpx; background: var(--grad-primary); color: #fff; font-size: 32rpx; font-weight: bold; border-radius: 44rpx; margin-top: 10rpx; }
.join-close { margin-top: 24rpx; color: var(--c-text-3); font-size: 26rpx; }
</style>
