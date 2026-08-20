<script setup>
import ListPage from '../components/ListPage.vue'
import { categoryApi } from '../api'

// 父级分类下拉选项：拉取全部分类供表单选择
async function loadParentOptions() {
  const res = await categoryApi.list({ page: 1, pageSize: 500 })
  return (res.list || []).map((c) => ({ label: c.name, value: c.id }))
}

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '分类名称' },
  { prop: 'parentName', label: '父分类', width: 130 },
  { prop: 'sort', label: '排序', width: 80 },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'name', label: '分类名称', required: true },
  { prop: 'parentId', label: '父级分类', type: 'select', loadOptions: loadParentOptions },
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
