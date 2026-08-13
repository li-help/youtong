<script setup>
import ListPage from '../components/ListPage.vue'
import { activityApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'title', label: '活动标题' },
  { prop: 'cover', label: '活动封面', type: 'image', width: 90 },
  { prop: 'start_time', label: '开始时间', width: 150 },
  { prop: 'end_time', label: '结束时间', width: 150 },
  { prop: 'status', label: '状态', tag: { 1: { text: '进行中', type: 'success' }, 0: { text: '已结束', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '活动标题', required: true },
  { prop: 'cover', label: '活动封面', type: 'image' },
  { prop: 'start_time', label: '开始时间', type: 'datetime', required: true },
  { prop: 'end_time', label: '结束时间', type: 'datetime', required: true },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '进行中', value: 1 },
    { label: '已结束', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="活动列表"
    :api="activityApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="activityApi.save"
    :remove-api="activityApi.remove"
    keyword-placeholder="活动标题"
  />
</template>
