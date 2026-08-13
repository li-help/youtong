<script setup>
import ListPage from '../components/ListPage.vue'
import { sysAccountApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'username', label: '账号' },
  { prop: 'nickname', label: '昵称' },
  { prop: 'role', label: '角色', tag: { admin: { text: '管理员', type: 'danger' }, operator: { text: '运营', type: 'info' } } },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
  { prop: 'remark', label: '备注' },
  { prop: 'created_at', label: '创建时间', width: 160 },
]

const formFields = [
  { prop: 'username', label: '账号', required: true },
  { prop: 'nickname', label: '昵称', required: true },
  { prop: 'password', label: '密码', type: 'password', placeholder: '新增必填；编辑留空则不修改', required: true },
  { prop: 'role', label: '角色', type: 'select', required: true, options: [
    { label: '管理员', value: 'admin' },
    { label: '运营', value: 'operator' },
  ] },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
  { prop: 'remark', label: '备注', type: 'textarea' },
]
</script>

<template>
  <ListPage
    title="账号管理"
    :api="sysAccountApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="sysAccountApi.save"
    :remove-api="sysAccountApi.remove"
    keyword-placeholder="账号/昵称"
  />
</template>
