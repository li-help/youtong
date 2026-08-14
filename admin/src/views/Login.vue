<template>
  <div class="login-wrap">
    <el-card class="login-card" shadow="always">
      <div class="login-title">优通后台管理系统</div>
      <el-form :model="form" :rules="rules" ref="formRef" @keyup.enter="onSubmit">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="密码"
            :prefix-icon="Lock"
          />
        </el-form-item>
        <el-button type="primary" :loading="loading" class="login-btn" @click="onSubmit">
          登 录
        </el-button>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { authApi } from '../api'

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '' })

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function onSubmit() {
  await formRef.value.validate()
  loading.value = true
  try {
    const res = await authApi.login(form.username, form.password)
    const token = res.token
    const user = res.user || {}
    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(user))
    ElMessage.success('登录成功')
    router.replace('/')
  } catch (err) {
    // 业务错误信息已由 request 拦截器统一弹出，这里不再重复提示
    console.warn('login failed:', err?.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ff6699 0%, #ff99cc 100%);
}
.login-card {
  width: 360px;
  border-radius: 12px;
}
.login-title {
  text-align: center;
  font-size: 20px;
  font-weight: 600;
  color: #ff6699;
  margin-bottom: 24px;
}
.login-btn {
  width: 100%;
}
</style>
