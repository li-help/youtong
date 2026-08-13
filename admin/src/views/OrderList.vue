<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import ListPage from '../components/ListPage.vue'
import { orderApi } from '../api'

const listRef = ref(null)

const columns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'order_no', label: '订单号', width: 200 },
  { prop: 'amount', label: '金额(元)', formatter: (r, c, v) => `¥${v}` },
  { prop: 'status', label: '状态', tag: {
    0: { text: '待支付', type: 'warning' },
    1: { text: '已支付', type: 'primary' },
    2: { text: '已核销', type: 'success' },
    3: { text: '已取消', type: 'danger' },
  } },
  { prop: 'created_at', label: '下单时间', width: 160 },
]

const formFields = [
  { prop: 'order_no', label: '订单号', required: true },
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
    :form-fields="formFields"
    :save-api="orderApi.save"
    :remove-api="orderApi.remove"
    :status-options="[{ label: '待支付', value: 0 }, { label: '已支付', value: 1 }, { label: '已核销', value: 2 }, { label: '已取消', value: 3 }]"
    keyword-placeholder="订单号"
    @verify="onVerify"
  />
</template>
