<script setup>
import ListPage from '../components/ListPage.vue'
import { faqApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'category', label: '分类', width: 130 },
  { prop: 'question', label: '标准问题' },
  { prop: 'keywords', label: '匹配关键词' },
  { prop: 'answer', label: '标准回答' },
  { prop: 'hitCount', label: '命中次数', width: 100 },
  { prop: 'sort', label: '排序权重', width: 90 },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'category', label: '问题分类', required: true },
  { prop: 'question', label: '标准问题', required: true },
  { prop: 'keywords', label: '匹配关键词', placeholder: '多个关键词用逗号分隔，如：退费,取消' },
  { prop: 'answer', label: '标准回答内容', type: 'textarea', required: true },
  { prop: 'sort', label: '排序权重', type: 'number', placeholder: '数字越大越优先' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="FAQ 知识库"
    :api="faqApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="faqApi.save"
    :remove-api="faqApi.remove"
    keyword-placeholder="分类/问题/关键词"
  />
</template>
