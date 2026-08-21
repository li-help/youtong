<template>
  <view class="page">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">{{ isEdit ? '编辑地址' : '新增地址' }}</text>
      </view>
    </view>

    <view class="form">
      <view class="form-item">
        <text class="label">收货人</text>
        <input class="input" v-model="form.name" placeholder="请输入收货人姓名" />
      </view>
      <view class="form-item">
        <text class="label">联系电话</text>
        <input class="input" v-model="form.phone" type="number" maxlength="11" placeholder="请输入手机号" />
      </view>
      <view class="form-item">
        <text class="label">所在地区</text>
        <input class="input" v-model="form.region" placeholder="如：广东省 深圳市 南山区" />
      </view>
      <view class="form-item">
        <text class="label">详细地址</text>
        <textarea class="textarea" v-model="form.detail" placeholder="街道、门牌号等详细信息" :maxlength="120" />
      </view>
      <view class="form-item switch-item">
        <text class="label">设为默认地址</text>
        <switch :checked="form.isDefault === 1" color="#F6B51E" @change="onSwitch" />
      </view>
    </view>

    <view class="bottom-bar">
      <button class="btn btn--primary add-btn" @click="onSave">保存地址</button>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { addressApi } from '../../../api/index.js'

const id = ref(null)
const isEdit = computed(() => !!id.value)
const form = ref({ name: '', phone: '', region: '', detail: '', isDefault: 0 })

onLoad((options) => {
  if (options && options.id) {
    id.value = Number(options.id)
    loadDetail()
  }
})

async function loadDetail() {
  try {
    const r = await addressApi.list()
    const list = r || []
    const target = list.find(a => a.id === id.value)
    if (target) {
      form.value = {
        id: target.id,
        name: target.name || '',
        phone: target.phone || '',
        region: target.region || '',
        detail: target.detail || '',
        isDefault: target.isDefault || 0
      }
    }
  } catch (e) { /* 忽略 */ }
}

function onSwitch(e) {
  form.value.isDefault = e.detail.value ? 1 : 0
}

function goBack() { uni.navigateBack() }

async function onSave() {
  if (!form.value.name.trim()) { uni.showToast({ title: '请填写收货人姓名', icon: 'none' }); return }
  if (!/^1\d{10}$/.test(form.value.phone.trim())) { uni.showToast({ title: '请输入正确的手机号', icon: 'none' }); return }
  if (!form.value.detail.trim()) { uni.showToast({ title: '请填写详细地址', icon: 'none' }); return }
  try {
    const payload = { ...form.value }
    if (id.value) payload.id = id.value
    await addressApi.save(payload)
    uni.showToast({ title: '保存成功', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 600)
  } catch (e) {
    uni.showToast({ title: '保存失败，请稍后重试', icon: 'none' })
  }
}
</script>

<style scoped>
.page { min-height: 100vh; background: #F5F6FA; }
.form { margin: 24rpx 32rpx; background: #fff; border-radius: 24rpx; padding: 0 32rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.04); }
.form-item { display: flex; align-items: center; padding: 28rpx 0; border-bottom: 1rpx solid #F5F5F5; }
.form-item:last-child { border-bottom: none; }
.label { width: 160rpx; font-size: 28rpx; color: #2D2D2D; font-weight: 600; flex-shrink: 0; }
.input { flex: 1; font-size: 28rpx; color: #2D2D2D; }
.textarea { flex: 1; font-size: 28rpx; color: #2D2D2D; height: 120rpx; padding: 8rpx 0; }
.switch-item { justify-content: space-between; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; padding: 20rpx 32rpx calc(20rpx + env(safe-area-inset-bottom)); background: #fff; box-shadow: 0 -4rpx 20rpx rgba(0,0,0,0.04); }
.add-btn { width: 100%; }
</style>
