<script setup>
import ListPage from '../components/ListPage.vue'
import { serviceApi, storeApi, sysAccountApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '客服名称' },
  { prop: 'avatar', label: '头像', type: 'image', width: 90 },
  { prop: 'storeName', label: '所属门店' },
  { prop: 'accountName', label: '工作台账号' },
  { prop: 'phone', label: '联系电话' },
  { prop: 'online', label: '在线', tag: { 1: { text: '在线', type: 'success' }, 0: { text: '离线', type: 'danger' } } },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

// 所属门店下拉：0 = 全平台官方客服
async function loadStoreOptions() {
  const res = await storeApi.list({ page: 1, pageSize: 200 })
  const list = res?.data?.list || []
  return [{ label: '全平台（官方客服）', value: 0 }, ...list.map((s) => ({ label: s.name, value: s.id }))]
}

// 绑定工作台账号：客服用该账号登录后台「客服工作台」接待会话
async function loadAccountOptions() {
  const res = await sysAccountApi.list({ page: 1, pageSize: 200 })
  const list = res?.data?.list || []
  return list.map((a) => ({
    label: (a.nickname && a.nickname.trim() ? `${a.nickname}（${a.username}）` : a.username) + ` · ${a.role}`,
    value: a.id,
  }))
}

const formFields = [
  { prop: 'name', label: '客服名称', required: true },
  { prop: 'avatar', label: '头像', type: 'image' },
  { prop: 'phone', label: '联系电话', required: true },
  { prop: 'storeId', label: '所属门店', type: 'select', required: true, options: [{ label: '全平台（官方客服）', value: 0 }], loadOptions: loadStoreOptions },
  { prop: 'accountId', label: '工作台账号', type: 'select', required: true, options: [], loadOptions: loadAccountOptions },
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
