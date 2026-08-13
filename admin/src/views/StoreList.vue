<script setup>
import ListPage from '../components/ListPage.vue'
import { storeApi } from '../api'

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'name', label: '门店名称' },
  { prop: 'logo', label: '门店Logo', type: 'image', width: 90 },
  { prop: 'address', label: '地址' },
  { prop: 'score', label: '评分', width: 90 },
  { prop: 'intro', label: '简介' },
  { prop: 'lng', label: '经度', width: 110 },
  { prop: 'lat', label: '纬度', width: 110 },
  { prop: 'status', label: '营业状态', tag: { 1: { text: '营业', type: 'success' }, 0: { text: '歇业', type: 'danger' } } },
]

const formFields = [
  { prop: 'name', label: '门店名称', required: true },
  { prop: 'logo', label: '门店Logo', type: 'image' },
  { prop: 'address', label: '地址', required: true },
  { prop: 'score', label: '评分', type: 'number' },
  { prop: 'intro', label: '简介', type: 'textarea' },
  { prop: 'lng', label: '经度', type: 'number' },
  { prop: 'lat', label: '纬度', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '营业', value: 1 },
    { label: '歇业', value: 0 },
  ] },
]
</script>

<template>
  <ListPage
    title="店铺列表"
    :api="storeApi.list"
    :columns="columns"
    :form-fields="formFields"
    :save-api="storeApi.save"
    :remove-api="storeApi.remove"
    keyword-placeholder="门店名称/地址"
  />
</template>
