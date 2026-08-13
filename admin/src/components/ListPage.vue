<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const props = defineProps({
  title: { type: String, default: '' },
  api: { type: Function, required: true },       // (params) => Promise<{data:{list,total}}>
  columns: { type: Array, required: true },       // [{prop,label,width,formatter?}]
  keywordPlaceholder: { type: String, default: '请输入关键词' },
  showStatusFilter: { type: Boolean, default: true },
  // 状态筛选项，默认 [启用/禁用]。各业务可传 [{label,value}]
  statusOptions: { type: Array, default: () => [{ label: '启用', value: 1 }, { label: '禁用', value: 0 }] },
  // 弹窗表单字段：[{prop,label,type:'input|textarea|number|select',options?,required?}]
  formFields: { type: Array, default: () => [] },
  saveApi: { type: Function, default: null },     // (data) => Promise
  removeApi: { type: Function, default: null },   // (id) => Promise
})

const loading = ref(false)
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const keyword = ref('')
const status = ref('')

const emit = defineEmits(['add', 'edit', 'verify', 'remove'])

async function load() {
  loading.value = true
  try {
    const params = { page: page.value, pageSize: pageSize.value }
    if (keyword.value) params.keyword = keyword.value
    if (status.value !== '' && status.value !== null && status.value !== undefined) params.status = status.value
    const res = await props.api(params)
    const d = res || {}
    list.value = d.list || []
    total.value = d.total || 0
  } finally {
    loading.value = false
  }
}

function onSearch() { page.value = 1; load() }
function onReset() { keyword.value = ''; status.value = ''; page.value = 1; load() }
function onPageChange(p) { page.value = p; load() }
function onSizeChange(s) { pageSize.value = s; load() }

// ---------- 弹窗表单 ----------
const dialogVisible = ref(false)
const dialogMode = ref('add') // add | edit
const formRef = ref(null)
const form = reactive({})
const formLoading = ref(false)

function openDialog(mode, row) {
  dialogMode.value = mode
  // 初始化表单字段
  props.formFields.forEach((f) => {
    form[f.prop] = f.type === 'number' ? (row ? Number(row[f.prop]) || 0 : 0) : (row ? (row[f.prop] ?? '') : '')
  })
  if (row) form.id = row.id
  else delete form.id
  dialogVisible.value = true
}

function onAdd() {
  emit('add')
  if (props.formFields.length) openDialog('add')
}
function onEdit(row) {
  emit('edit', row)
  if (props.formFields.length) openDialog('edit', row)
}

async function onSubmit() {
  if (!props.saveApi) return
  await formRef.value?.validate(async (ok) => {
    if (!ok) return
    formLoading.value = true
    try {
      const payload = { ...form }
      // 密码类字段：留空则不提交（编辑时保留原密码）
      props.formFields.forEach((f) => {
        if (f.type === 'password' && payload[f.prop] === '') {
          delete payload[f.prop]
        }
      })
      await props.saveApi(payload)
      ElMessage.success(dialogMode.value === 'add' ? '新增成功' : '保存成功')
      dialogVisible.value = false
      load()
    } finally {
      formLoading.value = false
    }
  })
}

function onRemove(row) {
  emit('remove', row)
  if (!props.removeApi) return
  // 取第一个非 id 文本列作为名称，避免依赖列顺序
  const nameCol = props.columns.find((c) => c.prop !== 'id' && !c.tag)
  const name = (nameCol && row[nameCol.prop]) || row.id
  ElMessageBox.confirm(`确认删除「${name}」?`, '提示', { type: 'warning' })
    .then(async () => {
      await props.removeApi(row.id)
      ElMessage.success('已删除')
      load()
    })
    .catch(() => {})
}

function onVerify(row) {
  emit('verify', row)
}

onMounted(load)
watch(() => props.api, load)
defineExpose({ load })
</script>

<template>
  <div class="list-page">
    <div class="toolbar" v-if="title">
      <h2 class="page-title">{{ title }}</h2>
    </div>

    <el-card shadow="never" class="filter-card">
      <el-form :inline="true" class="filter-form">
        <el-form-item>
          <el-input v-model="keyword" :placeholder="keywordPlaceholder" clearable style="width: 220px" />
        </el-form-item>
        <el-form-item v-if="showStatusFilter">
          <el-select v-model="status" placeholder="状态" clearable style="width: 130px">
            <el-option v-for="opt in statusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSearch">查询</el-button>
          <el-button @click="onReset">重置</el-button>
          <el-button type="success" @click="onAdd">新增</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table :data="list" row-key="id" v-loading="loading" stripe style="width: 100%" header-cell-class-name="pink-header">
        <template #empty>
          <span v-if="loading">加载中…</span>
          <span v-else>暂无数据</span>
        </template>
        <el-table-column
          v-for="col in columns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
          :width="col.width"
          show-overflow-tooltip
        >
          <template v-if="col.tag" #default="{ row }">
            <el-tag
              :type="(col.tag[row[col.prop]] || {}).type || 'info'"
              :effect="(col.tag[row[col.prop]] || {}).effect || 'light'"
            >{{ (col.tag[row[col.prop]] || {}).text ?? row[col.prop] }}</el-tag>
          </template>
          <template v-else-if="col.type === 'image'" #default="{ row }">
            <el-image
              v-if="row[col.prop]"
              :src="row[col.prop]"
              style="width: 50px; height: 50px; border-radius: 4px; display: block;"
              :preview-src-list="[row[col.prop]]"
              preview-teleported
              fit="cover"
            />
            <span v-else style="color: var(--el-text-color-placeholder)">-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="onEdit(row)">编辑</el-button>
            <el-button link type="success" v-if="$attrs.onVerify" @click="onVerify(row)">核销</el-button>
            <el-button link type="danger" @click="onRemove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="pager"
        background
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="page"
        :page-sizes="[10, 20, 50]"
        @current-change="onPageChange"
        @size-change="onSizeChange"
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogMode === 'add' ? '新增' : '编辑'"
      width="520px"
      append-to-body
    >
      <el-form ref="formRef" :model="form" label-width="90px">
        <el-form-item
          v-for="f in formFields"
          :key="f.prop"
          :label="f.label"
          :prop="f.prop"
          :rules="(f.required && !(f.type === 'password' && dialogMode === 'edit')) ? [{ required: true, message: `请输入${f.label}`, trigger: 'blur' }] : []"
        >
          <el-input
            v-if="!f.type || f.type === 'input'"
            v-model="form[f.prop]"
            :placeholder="`请输入${f.label}`"
          />
          <el-input
            v-else-if="f.type === 'password'"
            v-model="form[f.prop]"
            type="password"
            show-password
            :placeholder="`请输入${f.label}`"
          />
          <el-input
            v-else-if="f.type === 'textarea'"
            v-model="form[f.prop]"
            type="textarea"
            :rows="f.rows || 3"
            :placeholder="`请输入${f.label}`"
          />
          <el-input-number
            v-else-if="f.type === 'number'"
            v-model="form[f.prop]"
            :min="0"
            controls-position="right"
            style="width: 100%"
          />
          <el-select
            v-else-if="f.type === 'select'"
            v-model="form[f.prop]"
            placeholder="请选择"
            style="width: 100%"
          >
            <el-option
              v-for="opt in f.options"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
          <el-date-picker
            v-else-if="f.type === 'datetime'"
            v-model="form[f.prop]"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            :placeholder="`请选择${f.label}`"
            style="width: 100%"
          />
          <div v-else-if="f.type === 'image'">
            <el-input
              v-model="form[f.prop]"
              :placeholder="`请输入${f.label} URL`"
              clearable
            />
            <div v-if="form[f.prop]" style="margin-top: 8px;">
              <el-image
                :src="form[f.prop]"
                style="width: 100px; height: 100px; border-radius: 4px; border: 1px solid var(--el-border-color);"
                fit="cover"
              />
            </div>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="formLoading" @click="onSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.list-page { display: flex; flex-direction: column; gap: 12px; }
.page-title { margin: 0; font-size: 20px; color: var(--text-heading); }
.filter-card :deep(.el-card__body) { padding: 12px 16px; }
.pager { margin-top: 12px; justify-content: flex-end; display: flex; }
/* 表头文字粉色加粗 */
.list-page :deep(.pink-header) {
  color: var(--brand) !important;
  font-weight: 700 !important;
  background: var(--brand-bg) !important;
}
</style>
