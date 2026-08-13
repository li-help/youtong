<script setup>
import ListPage from '../components/ListPage.vue'
import { adPositionApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '广告位名称' },
  { prop: 'code', label: '编码' },
  { prop: 'size', label: '尺寸' },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'name', label: '广告位名称', required: true },
  { prop: 'code', label: '编码', required: true },
  { prop: 'size', label: '尺寸', required: true },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="广告位"
    :api="adPositionApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="adPositionApi.save"
    :remove-api="adPositionApi.remove"
    keyword-placeholder="名称/编码"
  />
</template>
