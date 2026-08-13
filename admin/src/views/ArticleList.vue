<script setup>
import ListPage from '../components/ListPage.vue'
import { articleApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'title', label: '标题' },
  { prop: 'author', label: '作者' },
  { prop: 'status', label: '状态', tag: { 1: { text: '已发布', type: 'success' }, 0: { text: '草稿', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '标题', required: true },
  { prop: 'author', label: '作者', required: true },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '已发布', value: 1 },
    { label: '草稿', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="文章列表"
    :api="articleApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="articleApi.save"
    :remove-api="articleApi.remove"
    keyword-placeholder="文章标题"
  />
</template>
