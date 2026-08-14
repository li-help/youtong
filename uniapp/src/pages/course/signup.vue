<template>
  <view class="signup">
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
.signup { padding-bottom: 160rpx; background: #FFF8E1; min-height: 100vh; }
.card { margin: 24rpx; }
.course-summary { display: flex; align-items: center; }
.cs-cover { width: 160rpx; height: 120rpx; border-radius: 14rpx; background: #FFE0B2; flex-shrink: 0; }
.cs-info { flex: 1; margin-left: 20rpx; display: flex; flex-direction: column; }
.cs-title { font-size: 32rpx; font-weight: bold; }
.form-item { margin-bottom: 28rpx; }
.label { font-size: 28rpx; color: #555; display: block; margin-bottom: 12rpx; }
.input { background: #FFF8E1; border-radius: 12rpx; padding: 20rpx; font-size: 28rpx; }
.textarea { background: #FFF8E1; border-radius: 12rpx; padding: 20rpx; font-size: 28rpx; width: 100%; height: 160rpx; }
.ph { color: #ccc; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; display: flex; align-items: center; padding: 16rpx 24rpx; background: #fff; box-shadow: 0 -4rpx 16rpx rgba(0,0,0,.05); }
.total { flex: 1; font-size: 28rpx; }
.pay-btn { width: 320rpx; }
</style>
