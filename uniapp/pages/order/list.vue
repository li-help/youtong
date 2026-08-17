<template>
  <view class="orders">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">我的订单</text>
      </view>
    </view>
    <view class="tabs">
      <view class="tab" :class="{ active: active === '' }" @click="change('')">全部</view>
      <view class="tab" :class="{ active: active === 0 }" @click="change(0)">待支付</view>
      <view class="tab" :class="{ active: active === 1 }" @click="change(1)">已支付</view>
      <view class="tab" :class="{ active: active === 2 }" @click="change(2)">已核销</view>
    </view>

    <scroll-view scroll-y class="scroll">
      <view class="card order-card" v-for="o in list" :key="o.id">
        <view class="o-top">
          <text class="o-no">订单号：{{ o.order_no || ('YT' + o.id) }}</text>
          <text class="o-status" :class="'s' + o.status">{{ o.status_text || statusText(o.status) }}</text>
        </view>
        <view class="o-amount">金额：<text class="price">¥{{ o.amount || '0' }}</text></view>
        <view class="o-time text-muted">下单时间：{{ o.created_at || '—' }}</view>
        <view class="o-actions" v-if="o.status === 1">
          <text class="verify-btn" @click="onVerify(o)">核销</text>
        </view>
      </view>
      <view v-if="!list.length" class="empty">暂无订单</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { orderApi } from '../../api/index.js'

const active = ref('')
const list = ref([])

function statusText(s) {
  return ['待支付', '已支付', '已核销', '已取消'][s] || '未知'
}

async function load() {
  try {
    const params = { page: 1, pageSize: 30 }
    if (active.value !== '') params.status = active.value
    const r = await orderApi.list(params)
    list.value = (r && r.list) ? r.list : []
  } catch (e) {
    list.value = [
      { id: 1, order_no: 'YT20260101001', status: 1, status_text: '已支付', amount: '199', created_at: '2026-01-01 10:00' },
      { id: 2, order_no: 'YT20260102002', status: 0, status_text: '待支付', amount: '299', created_at: '2026-01-02 14:00' }
    ]
  }
}

function change(s) { active.value = s; load() }
function goBack() { uni.navigateBack() }

async function onVerify(o) {
  try {
    await orderApi.verify(o.id)
    uni.showToast({ title: '核销成功', icon: 'success' })
    load()
  } catch (e) {
    uni.showToast({ title: '后端未连接', icon: 'none' })
  }
}

onMounted(load)
</script>

<style scoped>
.orders { min-height: 100vh; background: #F5F6FA; }
.tabs { display: flex; gap: 16rpx; padding: 24rpx 32rpx; }
.tab { flex: 1; text-align: center; font-size: 28rpx; color: #888; padding: 14rpx 0; background: #fff; border-radius: 36rpx; box-shadow: 0 4rpx 14rpx rgba(0,0,0,0.03); }
.tab.active { color: #fff; font-weight: bold; background: linear-gradient(135deg, #FF9F2E, #F6B51E); box-shadow: 0 8rpx 24rpx rgba(246,181,30,0.30); }
.scroll { height: calc(100vh - 88rpx - var(--status-bar-height, 20rpx) - 120rpx); padding: 0 32rpx; }
.order-card { display: flex; flex-direction: column; }
.o-top { display: flex; justify-content: space-between; align-items: center; }
.o-no { font-size: 26rpx; color: #888; }
.o-status { font-size: 24rpx; padding: 4rpx 18rpx; border-radius: 20rpx; }
.s0 { color: #FF7043; background: #FFE0B2; }
.s1 { color: #FFA000; background: #FFF3E0; }
.s2 { color: #43a047; background: #E8F5E9; }
.s3 { color: #999; background: #EEE; }
.o-amount { font-size: 28rpx; margin: 12rpx 0; color: #2D2D2D; }
.o-time { font-size: 24rpx; color: #bbb; }
.o-actions { display: flex; justify-content: flex-end; margin-top: 12rpx; }
.verify-btn { font-size: 26rpx; color: #fff; background: linear-gradient(135deg, #FF9F2E, #F6B51E); border-radius: 36rpx; padding: 10rpx 32rpx; box-shadow: 0 8rpx 24rpx rgba(246,181,30,0.30); }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
