<script setup>
import ListPage from '../components/ListPage.vue'
import { userApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'name', label: '用户名称' },
  { prop: 'code', label: '编码' },
  { prop: 'phone', label: '手机号' },
  { prop: 'status', label: '状态', tag: { 1: { text: '正常', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
  { prop: 'remark', label: '备注' },
  { prop: 'updated_at', label: '更新时间', width: 160 },
]

const formFields = [
  { prop: 'name', label: '用户名称', required: true },
  { prop: 'code', label: '编码', required: true },
  { prop: 'phone', label: '手机号' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '正常', value: 1 },
    { label: '禁用', value: 0 },
  ] },
  { prop: 'remark', label: '备注', type: 'textarea' },
]
</script>

<template>
  <ListPage
    title="用户列表"
    :api="userApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="userApi.save"
    :remove-api="userApi.remove"
    keyword-placeholder="名称/编码"
  />
</template>
