<script setup>
import ListPage from '../components/ListPage.vue'
import { categoryApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '分类名称' },
  { prop: 'parent_id', label: '父级ID', width: 90 },
  { prop: 'sort', label: '排序', width: 80 },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'name', label: '分类名称', required: true },
  { prop: 'parent_id', label: '父级ID', type: 'number' },
  { prop: 'sort', label: '排序', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="分类列表"
    :api="categoryApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="categoryApi.save"
    :remove-api="categoryApi.remove"
    keyword-placeholder="分类名称"
  />
</template>
