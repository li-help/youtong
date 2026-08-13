<script setup>
import ListPage from '../components/ListPage.vue'
import { serviceApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '客服名称' },
  { prop: 'avatar', label: '头像', type: 'image', width: 90 },
  { prop: 'phone', label: '联系电话' },
  { prop: 'online', label: '在线', tag: { 1: { text: '在线', type: 'success' }, 0: { text: '离线', type: 'danger' } } },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'name', label: '客服名称', required: true },
  { prop: 'avatar', label: '头像', type: 'image' },
  { prop: 'phone', label: '联系电话', required: true },
  { prop: 'online', label: '在线', type: 'select', required: true, options: [
    { label: '在线', value: 1 },
    { label: '离线', value: 0 },
  ] },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="客服列表"
    :api="serviceApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="serviceApi.save"
    :remove-api="serviceApi.remove"
    keyword-placeholder="客服名称"
  />
</template>
