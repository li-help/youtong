<script setup>
import ListPage from '../components/ListPage.vue'
import { videoApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'title', label: '标题' },
  { prop: 'duration', label: '时长(秒)', width: 100 },
  { prop: 'category_id', label: '分类ID', width: 90 },
  { prop: 'status', label: '状态', tag: { 1: { text: '上线', type: 'success' }, 0: { text: '下线', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '标题', required: true },
  { prop: 'duration', label: '时长(秒)', type: 'number' },
  { prop: 'category_id', label: '分类ID', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '上线', value: 1 },
    { label: '下线', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="视频列表"
    :api="videoApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="videoApi.save"
    :remove-api="videoApi.remove"
    keyword-placeholder="视频标题"
  />
</template>
