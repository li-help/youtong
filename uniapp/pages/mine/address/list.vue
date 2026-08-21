<template>
  <view class="page">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">收货地址</text>
      </view>
    </view>

    <scroll-view scroll-y class="scroll">
      <view class="addr-card" v-for="a in list" :key="a.id" @click="goEdit(a)">
        <view class="a-top">
          <view class="a-name">{{ a.name }}<text class="a-phone">{{ a.phone }}</text></view>
          <text v-if="a.isDefault === 1" class="tag">默认</text>
        </view>
        <view class="a-region">{{ a.region || '' }}</view>
        <view class="a-detail">{{ a.detail }}</view>
        <view class="a-bottom">
          <view class="a-default" @click.stop="toggleDefault(a)">
            <text class="radio" :class="{ on: a.isDefault === 1 }"></text>
            <text>设为默认</text>
          </view>
          <view class="a-actions">
            <text class="a-edit" @click.stop="goEdit(a)">编辑</text>
            <text class="a-del" @click.stop="onDelete(a)">删除</text>
          </view>
        </view>
      </view>

      <view v-if="!list.length" class="empty">
        <text class="empty-icon">📍</text>
        <text>还没有收货地址，点击下方按钮添加</text>
      </view>
    </scroll-view>

    <view class="bottom-bar">
      <button class="btn btn--primary add-btn" @click="goAdd">+ 新增收货地址</button>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { addressApi } from '../../../api/index.js'

const list = ref([])

async function load() {
  try {
    const r = await addressApi.list()
    list.value = r || []
  } catch (e) {
    uni.showToast({ title: '加载失败，请稍后重试', icon: 'none' })
  }
}

function goBack() { uni.navigateBack() }
function goAdd() { uni.navigateTo({ url: '/pages/mine/address/edit' }) }
function goEdit(a) { uni.navigateTo({ url: '/pages/mine/address/edit?id=' + a.id }) }

async function toggleDefault(a) {
  if (a.isDefault === 1) return
  try {
    await addressApi.setDefault(a.id)
    uni.showToast({ title: '已设为默认', icon: 'success' })
    load()
  } catch (e) {
    uni.showToast({ title: '操作失败，请稍后重试', icon: 'none' })
  }
}

function onDelete(a) {
  uni.showModal({
    title: '删除地址',
    content: '确定删除该收货地址吗？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await addressApi.remove(a.id)
        uni.showToast({ title: '已删除', icon: 'success' })
        load()
      } catch (e) {
        uni.showToast({ title: '删除失败，请稍后重试', icon: 'none' })
      }
    }
  })
}

onShow(load)
</script>

<style scoped>
.page { min-height: 100vh; background: #F5F6FA; }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx) - 160rpx); padding: 24rpx 32rpx; }
.addr-card { background: #fff; border-radius: 24rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.04); padding: 32rpx; margin-bottom: 24rpx; }
.a-top { display: flex; align-items: center; justify-content: space-between; }
.a-name { font-size: 32rpx; font-weight: 700; color: #2D2D2D; }
.a-phone { font-size: 26rpx; color: #888; font-weight: 400; margin-left: 16rpx; }
.a-region { font-size: 26rpx; color: #999; margin-top: 12rpx; }
.a-detail { font-size: 28rpx; color: #444; margin-top: 6rpx; line-height: 1.6; }
.a-bottom { display: flex; align-items: center; justify-content: space-between; margin-top: 24rpx; padding-top: 20rpx; border-top: 1rpx solid #F5F5F5; }
.a-default { display: flex; align-items: center; font-size: 26rpx; color: #666; }
.radio { width: 32rpx; height: 32rpx; border-radius: 50%; border: 3rpx solid #DDD; margin-right: 12rpx; display: inline-block; }
.radio.on { border-color: #F6B51E; background: radial-gradient(circle, #F6B51E 0 30%, #fff 32%); }
.a-actions { display: flex; gap: 32rpx; }
.a-edit { font-size: 26rpx; color: #666; }
.a-del { font-size: 26rpx; color: #E53935; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; padding: 20rpx 32rpx calc(20rpx + env(safe-area-inset-bottom)); background: #fff; box-shadow: 0 -4rpx 20rpx rgba(0,0,0,0.04); }
.add-btn { width: 100%; }
.empty { display: flex; flex-direction: column; align-items: center; gap: 16rpx; }
.empty-icon { font-size: 80rpx; }
</style>
