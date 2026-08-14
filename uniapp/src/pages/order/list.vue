<template>
  <view class="orders">
    <view class="status-bar"></view>
    <view class="tabs">
      <view class="tab" :class="{ active: active === '' }" @click="change('')">全部</view>
      <view class="tab" :class="{ active: active === 0 }" @click="change(0)">待支付</view>
      <view class="tab" :class="{ active: active === 1 }" @click="change(1)">已支付</view>
      <view class="tab" :class="{ active: active === 2 }" @click="change(2)">已核销</view>
    </view>

    <scroll-view scroll-y class="scroll">
      <view class="card order-card" v-for="o in list" :key="o.id">
        <view class="o-top">
          <text class="o-no">订单号：{{ o.orderNo || ('YT' + o.id) }}</text>
          <text class="o-status" :class="'s' + o.status">{{ o.statusText || statusText(o.status) }}</text>
        </view>
        <view class="o-amount">金额：<text class="price">¥{{ o.amount || '0' }}</text></view>
        <view class="o-time text-muted">下单时间：{{ o.createdAt || '—' }}</view>
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
    const r = await orderApi.list({ page: 1, pageSize: 30, status: active.value === '' ? undefined : active.value })
    list.value = (r && r.list) ? r.list : []
  } catch (e) {
    list.value = [
      { id: 1, orderNo: 'YT20260101001', status: 1, statusText: '已支付', amount: '199', createdAt: '2026-01-01 10:00' },
      { id: 2, orderNo: 'YT20260102002', status: 0, statusText: '待支付', amount: '299', createdAt: '2026-01-02 14:00' }
    ]
  }
}

function change(s) { active.value = s; load() }

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
.orders { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.tabs { display: flex; padding: 20rpx 24rpx; background: #FFF8E1; }
.tab { flex: 1; text-align: center; font-size: 28rpx; color: #777; padding: 12rpx 0; }
.tab.active { color: #FF8F00; font-weight: bold; border-bottom: 4rpx solid #FFA000; }
.scroll { height: calc(100vh - 200rpx); padding: 0 24rpx; }
.order-card { display: flex; flex-direction: column; }
.o-top { display: flex; justify-content: space-between; align-items: center; }
.o-no { font-size: 26rpx; color: #555; }
.o-status { font-size: 24rpx; padding: 4rpx 16rpx; border-radius: 20rpx; }
.s0 { color: #FF7043; background: #FFE0B2; }
.s1 { color: #FFA000; background: #FFF3E0; }
.s2 { color: #43a047; background: #E8F5E9; }
.s3 { color: #999; background: #EEE; }
.o-amount { font-size: 28rpx; margin: 12rpx 0; }
.o-time { font-size: 24rpx; }
.o-actions { display: flex; justify-content: flex-end; margin-top: 12rpx; }
.verify-btn { font-size: 26rpx; color: #fff; background: #FFA000; border-radius: 30rpx; padding: 8rpx 28rpx; }
.empty { text-align: center; color: #999; padding: 80rpx 0; }
</style>
