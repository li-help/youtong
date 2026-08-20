<script setup>
import ListPage from '../components/ListPage.vue'
import { courseApi, categoryApi } from '../api'

// 分类下拉选项：拉取全部分类供表单选择
async function loadCategoryOptions() {
  const res = await categoryApi.list({ page: 1, pageSize: 500 })
  return (res.list || []).map((c) => ({ label: c.name, value: c.id }))
}

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'title', label: '课程标题' },
  { prop: 'cover', label: '课程封面', type: 'image', width: 90 },
  { prop: 'price', label: '价格(元)', formatter: (r, c, v) => `¥${v}` },
  { prop: 'teacher', label: '讲师' },
  { prop: 'categoryName', label: '分类', width: 130 },
  { prop: 'status', label: '状态', tag: { 1: { text: '在售', type: 'success' }, 0: { text: '下架', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '课程标题', required: true },
  { prop: 'cover', label: '课程封面', type: 'image' },
  { prop: 'price', label: '价格(元)', type: 'number' },
  { prop: 'teacher', label: '讲师' },
  { prop: 'categoryId', label: '分类', type: 'select', loadOptions: loadCategoryOptions },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '在售', value: 1 },
    { label: '下架', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="课程列表"
    :api="courseApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="courseApi.save"
    :remove-api="courseApi.remove"
    keyword-placeholder="课程标题"
  />
</template>
