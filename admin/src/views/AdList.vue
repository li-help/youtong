<script setup>
import ListPage from '../components/ListPage.vue'
import { adApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'position_id', label: '广告位ID', width: 100 },
  { prop: 'title', label: '广告标题' },
  { prop: 'url', label: '跳转链接' },
  { prop: 'sort', label: '排序', width: 80 },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '广告标题', required: true },
  { prop: 'position_id', label: '广告位ID', type: 'number', required: true },
  { prop: 'url', label: '跳转链接' },
  { prop: 'sort', label: '排序', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="广告列表"
    :api="adApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="adApi.save"
    :remove-api="adApi.remove"
    keyword-placeholder="广告标题"
  />
</template>
