<template>
  <view class="profile">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">修改个人信息</text>
      </view>
    </view>

    <view class="form">
      <view class="avatar-row">
        <view class="avatar">
          <image v-if="form.avatar" :src="resolveImg(form.avatar)" mode="aspectFill" class="avatar-img" />
          <text v-else>{{ avatarText }}</text>
        </view>
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
import { uploadApi } from '../../api/index.js'
import { resolveImg } from '../../config.js'

const info = userStore.info || {}
const form = reactive({
  nickname: info.nickname || info.username || '',
  username: info.username || '',
  babyAge: info.babyAge || '',
  phone: info.phone || '',
  remark: info.remark || '',
  avatar: info.avatar || ''
})
const loading = ref(false)
const avatarText = (form.nickname || form.username || '童').charAt(0)

function goBack() { uni.navigateBack() }

function changeAvatar() {
  uni.chooseMedia({
    count: 1,
    mediaType: ['image'],
    sourceType: ['album', 'camera'],
    success: async (res) => {
      const temp = res.tempFiles[0].tempFilePath
      const data = await uploadApi.image(temp)
      if (data && data.url) {
        form.avatar = data.url
        uni.showToast({ title: '头像已更新', icon: 'success' })
      } else {
        uni.showToast({ title: '上传失败', icon: 'none' })
      }
    }
  })
}

async function onSave() {
  if (loading.value) return
  loading.value = true
  try {
    await userStore.updateProfile({
      nickname: form.nickname,
      phone: form.phone,
      babyAge: form.babyAge,
      remark: form.remark,
      avatar: form.avatar
    })
    uni.showToast({ title: '保存成功', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 500)
  } catch (e) {
    uni.showToast({ title: '保存失败，请重试', icon: 'none' })
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.profile { min-height: 100vh; background: #F5F6FA; }
.form { margin: 24rpx 32rpx; }
.avatar-row { display: flex; align-items: center; padding: 24rpx 0 40rpx; }
.avatar { width: 120rpx; height: 120rpx; border-radius: 50%; background: linear-gradient(135deg, #FF9F2E, #F6B51E); color: #fff; font-size: 52rpx; font-weight: bold; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 0 8rpx rgba(255, 179, 0, 0.18), 0 8rpx 24rpx rgba(246,181,30,0.30); overflow: hidden; }
.avatar-img { width: 120rpx; height: 120rpx; border-radius: 50%; }
.change-avatar { color: #E89B00; font-size: 28rpx; margin-left: 30rpx; }
.form-item { margin-bottom: 28rpx; }
.label { font-size: 28rpx; color: #555; display: block; margin-bottom: 12rpx; }
.input { background: #fff; border-radius: 16rpx; padding: 22rpx; font-size: 28rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.textarea { background: #fff; border-radius: 16rpx; padding: 22rpx; font-size: 28rpx; width: 100%; height: 160rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.ph { color: #ccc; }
.save-btn { margin-top: 20rpx; }
</style>
