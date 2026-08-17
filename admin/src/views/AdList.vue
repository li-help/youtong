<script setup>
import ListPage from '../components/ListPage.vue'
import { adApi } from '../api'

// 广告位固定为首页轮播 home_banner（position_id=1），列表与 App 首页轮播图一一对应
const POSITION_ID = 1

const columns = [
  { prop: 'id', label: 'ID', width: 70 },
  { prop: 'title', label: '广告标题' },
  { prop: 'image', label: '广告图片', type: 'image', width: 90 },
  { prop: 'url', label: '跳转链接' },
  { prop: 'startTime', label: '开始时间', width: 150 },
  { prop: 'endTime', label: '结束时间', width: 150 },
  { prop: 'sort', label: '排序', width: 80 },
  { prop: 'status', label: '状态', tag: { 1: { text: '启用', type: 'success' }, 0: { text: '禁用', type: 'danger' } } },
]

const formFields = [
  { prop: 'title', label: '广告标题', required: true },
  { prop: 'image', label: '广告图片', type: 'image' },
  { prop: 'url', label: '跳转链接' },
  { prop: 'startTime', label: '开始时间', type: 'datetime' },
  { prop: 'endTime', label: '结束时间', type: 'datetime' },
  { prop: 'sort', label: '排序', type: 'number' },
  { prop: 'status', label: '状态', type: 'select', required: true, options: [
    { label: '启用', value: 1 },
    { label: '禁用', value: 0 },
  ] },
]

// 新增/编辑广告统一固定到首页轮播广告位（positionId=1，驼峰与后端实体一致）
function saveAd(data) {
  return adApi.save({ ...data, positionId: POSITION_ID })
}
</script>

<template>
  <div>
    <el-tag type="warning" size="small" style="margin-bottom: 12px">
      广告位固定为「首页轮播」，列表与 App 首页轮播图一一对应
    </el-tag>
    <ListPage
      title="广告列表"
      :api="adApi.list"
      :extra-params="{ positionId: POSITION_ID }"
      :columns="columns"
      :form-fields="formFields"
      :save-api="saveAd"
      :remove-api="adApi.remove"
      keyword-placeholder="广告标题"
    />
  </div>
</template>
