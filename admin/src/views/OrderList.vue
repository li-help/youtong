<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import ListPage from '../components/ListPage.vue'
import { orderApi } from '../api'

const listRef = ref(null)

const columns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'order_no', label: '订单号', width: 160 },
  { prop: 'user_id', label: '用户ID', width: 90 },
  { prop: 'course_id', label: '课程ID', width: 90 },
  { prop: 'amount', label: '金额(元)', formatter: (r, c, v) => `¥${v}`, width: 100 },
  { prop: 'status_text', label: '状态', tag: {
    '待支付': { text: '待支付', type: 'warning' },
    '已支付': { text: '已支付', type: 'primary' },
    '已核销': { text: '已核销', type: 'success' },
    '已取消': { text: '已取消', type: 'danger' },
    '未知': { text: '未知', type: 'info' },
  }, width: 100 },
  { prop: 'paid_at', label: '支付时间', width: 160 },
  { prop: 'verify_at', label: '核销时间', width: 160 },
  { prop: 'created_at', label: '下单时间', width: 160 },
]

function onVerify(row) {
  orderApi.verify(row.id).then(() => {
    ElMessage.success(`订单 ${row.order_no} 已核销`)
    listRef.value?.load()
  })
}
</script>

<template>
  <ListPage
    ref="listRef"
    title="订单列表"
    :api="orderApi.list"
    :columns="columns"
    :show-status-filter="false"
    keyword-placeholder="订单号"
    @verify="onVerify"
  />
</template>
