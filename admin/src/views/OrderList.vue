<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import ListPage from '../components/ListPage.vue'
import { orderApi } from '../api'

const listRef = ref(null)

const columns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'orderNo', label: '订单号', width: 160 },
  { prop: 'userId', label: '用户ID', width: 90 },
  { prop: 'courseId', label: '课程ID', width: 90 },
  { prop: 'amount', label: '金额(元)', formatter: (r, c, v) => `¥${v}`, width: 100 },
  { prop: 'statusText', label: '状态', tag: {
    '待支付': { text: '待支付', type: 'warning' },
    '已支付': { text: '已支付', type: 'primary' },
    '已核销': { text: '已核销', type: 'success' },
    '已取消': { text: '已取消', type: 'danger' },
    '未知': { text: '未知', type: 'info' },
  }, width: 100 },
  { prop: 'paidAt', label: '支付时间', width: 160 },
  { prop: 'verifyAt', label: '核销时间', width: 160 },
  { prop: 'createdAt', label: '下单时间', width: 160 },
]

const formFields = [
  { prop: 'orderNo', label: '订单号', required: true },
  { prop: 'amount', label: '金额(元)', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '待支付', value: 0 },
    { label: '已支付', value: 1 },
    { label: '已核销', value: 2 },
    { label: '已取消', value: 3 },
  ] },
]

function onVerify(row) {
  orderApi.verify(row.id).then(() => {
    ElMessage.success(`订单 ${row.orderNo} 已核销`)
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
    :form-fields="formFields"
    :save-api="orderApi.save"
    :remove-api="orderApi.remove"
    :show-verify="true"
    :status-options="[{ label: '待支付', value: 0 }, { label: '已支付', value: 1 }, { label: '已核销', value: 2 }, { label: '已取消', value: 3 }]"
    keyword-placeholder="订单号"
    @verify="onVerify"
  />
</template>
