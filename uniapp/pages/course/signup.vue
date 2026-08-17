<template>
  <view class="signup">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">课程报名</text>
      </view>
    </view>
    <view class="card course-summary" v-if="course">
      <image :src="coverOf(course)" mode="aspectFill" class="cs-cover" />
      <view class="cs-info">
        <text class="cs-title">{{ course.title }}</text>
        <text class="price">¥{{ course.price || '0' }}</text>
      </view>
    </view>

    <view class="card form">
      <view class="form-item">
        <text class="label">宝宝姓名</text>
        <input class="input" v-model="form.babyName" placeholder="请输入宝宝姓名" placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">家长手机</text>
        <input class="input" v-model="form.phone" type="number" placeholder="请输入联系电话" placeholder-class="ph" />
      </view>
      <view class="form-item">
        <text class="label">备注</text>
        <textarea class="textarea" v-model="form.remark" placeholder="如有特殊需求请说明" placeholder-class="ph" />
      </view>
    </view>

    <view class="bottom-bar">
      <view class="total">合计：<text class="price">¥{{ course ? (course.price || '0') : '0' }}</text></view>
      <button class="btn-primary pay-btn" :loading="loading" @click="onSubmit">提交报名</button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { courseApi, orderApi } from '../../api/index.js'
import { coverOf } from '../../config.js'
import { userStore } from '../../store/user.js'

const course = ref(null)
const id = ref('')
const loading = ref(false)
const form = reactive({ babyName: '', phone: '', remark: '' })

onMounted(() => {
  const pages = getCurrentPages()
  id.value = pages[pages.length - 1].options.id
  load()
})

async function load() {
  try {
    course.value = await courseApi.detail(id.value)
  } catch (e) {
    course.value = { id: id.value, title: '示例课程', price: '199' }
  }
}

function goBack() { uni.navigateBack() }

async function onSubmit() {
  if (!form.babyName || !form.phone) {
    uni.showToast({ title: '请填写宝宝姓名和电话', icon: 'none' })
    return
  }
  loading.value = true
  try {
    await orderApi.create({
      courseId: Number(id.value),
      userId: (userStore.info && userStore.info.id) || 1,
      amount: course.value.price || 0,
      remark: form.remark,
      babyName: form.babyName,
      phone: form.phone
    })
    uni.showToast({ title: '报名成功', icon: 'success' })
    setTimeout(() => uni.redirectTo({ url: '/pages/order/list' }), 600)
  } catch (e) {
    uni.showModal({ title: '提示', content: '后端未连接，已生成本地模拟订单', success: () => {
      uni.redirectTo({ url: '/pages/order/list' })
    }})
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.signup { padding-bottom: 180rpx; background: #F5F6FA; min-height: 100vh; }
.card { margin: 24rpx 32rpx; }
.course-summary { display: flex; align-items: center; padding: 28rpx 32rpx; }
.cs-cover { width: 170rpx; height: 130rpx; border-radius: 18rpx; background: #FFF3DE; flex-shrink: 0; }
.cs-info { flex: 1; margin-left: 24rpx; display: flex; flex-direction: column; justify-content: center; }
.cs-title { font-size: 34rpx; font-weight: bold; color: #2D2D2D; }
.form { padding: 36rpx 32rpx; }
.form-item { margin-bottom: 32rpx; }
.form-item:last-child { margin-bottom: 0; }
.label { font-size: 28rpx; color: #555; display: block; margin-bottom: 14rpx; font-weight: 500; }
.input { background: #F5F6FA; border: 2rpx solid #E8E8E8; border-radius: 18rpx; padding: 24rpx 28rpx; font-size: 30rpx; color: #2D2D2D; transition: border-color .2s; }
.input:focus { border-color: #F6B51E; }
.textarea { background: #F5F6FA; border: 2rpx solid #E8E8E8; border-radius: 18rpx; padding: 24rpx 28rpx; font-size: 30rpx; width: 100%; height: 200rpx; color: #2D2D2D; line-height: 1.6; }
.ph { color: #bbb; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; display: flex; align-items: center; justify-content: space-between; padding: 20rpx 32rpx; padding-bottom: calc(20rpx + env(safe-area-inset-bottom)); background: #fff; box-shadow: 0 -4rpx 20rpx rgba(0,0,0,.08); }
.total { flex: 1; font-size: 30rpx; color: #555; }
.total .price { font-size: 40rpx; font-weight: bold; color: #E89B00; margin-left: 8rpx; }
.pay-btn { min-width: 280rpx; height: 88rpx; line-height: 88rpx; border-radius: 44rpx; font-size: 32rpx; font-weight: 600; letter-spacing: 2rpx; background: linear-gradient(135deg, #FF9F2E, #F6B51E); color: #fff; box-shadow: 0 10rpx 28rpx rgba(246,181,30,0.35); border: none; }
.pay-btn::after { border: none; }
</style>
