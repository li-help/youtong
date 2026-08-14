<template>
  <view class="profile">
    <view class="status-bar"></view>
    <view class="header">
      <text class="back" @click="goBack">‹</text>
      <text class="title">修改个人信息</text>
    </view>

    <view class="form">
      <view class="avatar-row">
        <view class="avatar">{{ avatarText }}</view>
        <text class="change-avatar" @click="changeAvatar">更换头像</text>
      </view>

      <view class="form-item">
        <text class="label">昵称</text>
        <input class="input" v-model="form.nickname" placeholder="请输入昵称" placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">用户名</text>
        <input class="input" v-model="form.username" disabled placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">宝宝年龄</text>
        <input class="input" v-model="form.babyAge" type="number" placeholder="宝宝年龄(岁)" placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">手机号</text>
        <input class="input" v-model="form.phone" type="number" placeholder="联系电话" placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">个性签名</text>
        <textarea class="textarea" v-model="form.remark" placeholder="一句话介绍自己" placeholder-class="ph" />
      </view>

      <button class="btn-primary save-btn" :loading="loading" @click="onSave">保 存</button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { userStore } from '../../store/user.js'

const info = userStore.info || {}
const form = reactive({
  nickname: info.nickname || info.username || '',
  username: info.username || '',
  babyAge: '',
  phone: '',
  remark: ''
})
const loading = ref(false)
const avatarText = (form.nickname || form.username || '童').charAt(0)

function goBack() { uni.navigateBack() }
function changeAvatar() { uni.showToast({ title: '演示版暂不支持', icon: 'none' }) }

async function onSave() {
  loading.value = true
  // 更新本地 store
  userStore.info = { ...userStore.info, nickname: form.nickname }
  uni.setStorageSync('userInfo', userStore.info)
  uni.showToast({ title: '保存成功', icon: 'success' })
  setTimeout(() => uni.navigateBack(), 500)
  loading.value = false
}
</script>

<style scoped>
.profile { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { display: flex; align-items: center; padding: 16rpx 24rpx 24rpx; }
.back { font-size: 56rpx; color: #FF8F00; width: 60rpx; }
.title { font-size: 38rpx; font-weight: bold; color: #FF8F00; margin-left: 16rpx; }
.form { margin: 24rpx; }
.avatar-row { display: flex; align-items: center; padding: 20rpx 0 40rpx; }
.avatar { width: 120rpx; height: 120rpx; border-radius: 50%; background: linear-gradient(135deg,#FFC107,#FFA000); color: #fff; font-size: 52rpx; font-weight: bold; display: flex; align-items: center; justify-content: center; }
.change-avatar { color: #FFA000; font-size: 28rpx; margin-left: 30rpx; }
.form-item { margin-bottom: 28rpx; }
.label { font-size: 28rpx; color: #555; display: block; margin-bottom: 12rpx; }
.input { background: #fff; border-radius: 12rpx; padding: 20rpx; font-size: 28rpx; }
.textarea { background: #fff; border-radius: 12rpx; padding: 20rpx; font-size: 28rpx; width: 100%; height: 160rpx; }
.ph { color: #ccc; }
.save-btn { margin-top: 20rpx; }
</style>
