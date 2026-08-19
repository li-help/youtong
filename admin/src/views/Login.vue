<template>
  <div class="login-wrap">
    <!-- 左侧品牌展示区 -->
    <div class="login-aside">
      <div class="aside-bg"></div>
      <div class="aside-content">
        <div class="brand">
          <div class="brand-logo">
            <svg viewBox="0 0 24 24" width="34" height="34" fill="none">
              <path d="M12 2.5l2.7 5.5 6 .9-4.35 4.25 1.03 5.98L12 16.9l-5.38 2.83 1.03-5.98L3.3 8.9l6-.9L12 2.5z"
                fill="#fff" />
            </svg>
          </div>
          <span class="brand-name">优童成长 · 管理后台</span>
        </div>

        <h1 class="aside-title">一站式运营中枢<br />让每一个成长瞬间被看见</h1>

        <ul class="feature-list">
          <li><span class="dot"></span>课程 / 活动 / 订单全链路管理</li>
          <li><span class="dot"></span>多端数据实时同步，运营一目了然</li>
          <li><span class="dot"></span>智能育儿助手，赋能家长服务</li>
        </ul>

        <div class="aside-foot">
          <span class="stat"><b>8+</b> 业务模块</span>
          <span class="stat"><b>3</b> 端协同</span>
          <span class="stat"><b>实时</b> 同步</span>
        </div>

        <div class="app-download">
          <div class="app-download-icon">
            <el-icon :size="18"><Download /></el-icon>
          </div>
          <div class="app-download-info">
            <div class="app-download-title">App 下载</div>
            <div class="app-download-sub">手机扫码直接安装</div>
          </div>
          <div v-if="qrDataUrl" class="app-download-qrcode">
            <img :src="qrDataUrl" alt="App 下载二维码" />
          </div>
        </div>
      </div>
    </div>

    <!-- 右侧登录表单区 -->
    <div class="login-main">
      <div class="login-glow login-glow-1"></div>
      <div class="login-glow login-glow-2"></div>

      <div class="login-card">
        <div class="card-logo">
          <div class="card-logo-icon">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none">
              <path d="M12 2.5l2.7 5.5 6 .9-4.35 4.25 1.03 5.98L12 16.9l-5.38 2.83 1.03-5.98L3.3 8.9l6-.9L12 2.5z"
                fill="#ff7a9c" />
            </svg>
          </div>
        </div>
        <div class="card-head">
          <div class="welcome">欢迎回来</div>
          <div class="welcome-sub">请输入账号信息以登录管理系统</div>
        </div>

        <el-form :model="form" :rules="rules" ref="formRef" @keyup.enter="onSubmit">
          <el-form-item prop="username">
            <el-input v-model="form.username" placeholder="用户名 / 手机号" :prefix-icon="User" size="large" />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              show-password
              placeholder="密码"
              :prefix-icon="Lock"
              size="large"
            />
          </el-form-item>

          <div class="row-between">
            <el-checkbox v-model="remember">记住我</el-checkbox>
            <el-link type="primary" :underline="false" class="fp">忘记密码？</el-link>
          </div>

          <el-button type="primary" :loading="loading" class="login-btn" size="large" @click="onSubmit">
            登 录
          </el-button>
        </el-form>

        <div class="card-foot">
          <span>优童成长社 · 运营控制台</span>
          <span class="muted">v1.0</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, Lock, Download } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import QRCode from 'qrcode'
import { authApi } from '../api'

// 扫码后跳转的 App 下载地址，发布前改成真实可访问的 APK 下载地址
const APP_DOWNLOAD_URL = import.meta.env.VITE_APP_DOWNLOAD_URL || 'http://localhost:3001/download/app-release.apk'
const APK_FILE_NAME = import.meta.env.VITE_APK_FILE_NAME || 'app-release.apk'
const qrDataUrl = ref('')

onMounted(async () => {
  try {
    qrDataUrl.value = await QRCode.toDataURL(APP_DOWNLOAD_URL, {
      width: 200,
      margin: 2,
      color: { dark: '#2b2730', light: '#ffffff' },
    })
  } catch (err) {
    console.warn('生成二维码失败:', err)
  }
})

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const remember = ref(true)
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
  overflow: hidden;
  background: #fff;
}

/* 入场动画 */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(18px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes floaty {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(14px, -18px); }
}

/* 左侧品牌区 */
.login-aside {
  position: relative;
  flex: 1 1 58%;
  min-width: 460px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  color: #fff;
  animation: fadeUp 0.7s ease both;
}
.aside-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(1200px 600px at 10% 0%, rgba(255, 122, 156, 0.95), transparent 60%),
    radial-gradient(900px 600px at 100% 100%, rgba(255, 153, 204, 0.9), transparent 55%),
    linear-gradient(135deg, #ff7a9c 0%, #f25c84 100%);
}
.aside-bg::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image:
    radial-gradient(rgba(255, 255, 255, 0.18) 1px, transparent 1px);
  background-size: 22px 22px;
  opacity: 0.5;
  mix-blend-mode: overlay;
}
.aside-content {
  position: relative;
  z-index: 1;
  padding: 0 80px 0 10vw;
  max-width: 640px;
  width: 100%;
}
.brand {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 72px;
  animation: fadeUp 0.7s ease 0.05s both;
}
.brand-logo {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.22);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}
.brand-name {
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.5px;
}
.aside-title {
  font-size: 42px;
  line-height: 1.3;
  font-weight: 800;
  margin: 0 0 36px;
  letter-spacing: 0;
  text-shadow: 0 4px 18px rgba(0, 0, 0, 0.12);
  animation: fadeUp 0.7s ease 0.12s both;
}
.feature-list {
  list-style: none;
  padding: 0;
  margin: 0 0 56px;
  display: flex;
  flex-direction: column;
  gap: 18px;
  animation: fadeUp 0.7s ease 0.24s both;
}
.feature-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 15px;
  opacity: 0.96;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 0 0 5px rgba(255, 255, 255, 0.25);
  flex: none;
}
.aside-foot {
  display: flex;
  gap: 40px;
  padding-top: 32px;
  border-top: 1px solid rgba(255, 255, 255, 0.3);
  animation: fadeUp 0.7s ease 0.3s both;
}
.stat {
  font-size: 14px;
  opacity: 0.92;
}
.stat b {
  display: block;
  font-size: 22px;
  font-weight: 800;
  margin-bottom: 2px;
}

.app-download {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: 28px;
  padding: 16px 20px;
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.24);
  border-radius: 16px;
  backdrop-filter: blur(6px);
  animation: fadeUp 0.7s ease 0.36s both;
}
.app-download-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.22);
  display: flex;
  align-items: center;
  justify-content: center;
  flex: none;
}
.app-download-title {
  font-size: 15px;
  font-weight: 700;
}
.app-download-sub {
  font-size: 12px;
  opacity: 0.85;
  margin-top: 2px;
}
.app-download-qrcode {
  margin-left: auto;
  width: 88px;
  height: 88px;
  padding: 6px;
  background: #fff;
  border-radius: 10px;
  flex: none;
}
.app-download-qrcode img {
  width: 100%;
  height: 100%;
  display: block;
  border-radius: 6px;
}

/* 右侧登录区 */
.login-main {
  position: relative;
  flex: 1 1 45%;
  min-width: 380px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fbfbfd;
}
.login-glow {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.45;
  pointer-events: none;
  animation: floaty 9s ease-in-out infinite;
}
.login-glow-1 {
  width: 280px;
  height: 280px;
  background: #ffd9e3;
  top: -60px;
  right: -40px;
}
.login-glow-2 {
  width: 240px;
  height: 240px;
  background: #ffe9c7;
  bottom: -50px;
  left: -30px;
  animation-delay: -4.5s;
}
.login-card {
  position: relative;
  z-index: 1;
  width: 380px;
  max-width: calc(100% - 48px);
  padding: 36px 36px 28px;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 24px 70px -22px rgba(242, 92, 132, 0.3), 0 8px 24px -12px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(255, 122, 156, 0.14);
  animation: fadeUp 0.8s ease 0.1s both;
}
.card-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 18px;
}
.card-logo-icon {
  width: 50px;
  height: 50px;
  border-radius: 14px;
  background: linear-gradient(135deg, #ffe3ec 0%, #ffd0de 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10px 22px -10px rgba(242, 92, 132, 0.6);
}
.card-head {
  margin-bottom: 26px;
  text-align: center;
}
.welcome {
  font-size: 24px;
  font-weight: 800;
  color: #2b2730;
  letter-spacing: -0.3px;
}
.welcome-sub {
  margin-top: 6px;
  font-size: 14px;
  color: #9b94a3;
}
.row-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 4px 0 22px;
}
.fp {
  font-size: 13px;
}
.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 4px;
  border-radius: 12px;
  background: linear-gradient(135deg, #ff7a9c 0%, #f25c84 100%);
  border: none;
  box-shadow: 0 10px 24px -8px rgba(242, 92, 132, 0.6);
  transition: transform 0.2s ease, box-shadow 0.2s ease, filter 0.2s ease;
}
.login-btn:hover {
  transform: translateY(-2px);
  filter: brightness(1.03);
  box-shadow: 0 16px 32px -10px rgba(242, 92, 132, 0.7);
}
.login-btn:active {
  transform: translateY(0);
}
.login-btn.is-loading {
  letter-spacing: 2px;
}
.card-foot {
  margin-top: 24px;
  padding-top: 18px;
  border-top: 1px solid #f0eef2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 12px;
  color: #b6b0bd;
}
.card-foot .muted {
  opacity: 0.7;
}

/* 输入框聚焦时的柔和反馈 */
.login-card :deep(.el-input__wrapper) {
  border-radius: 10px;
  box-shadow: 0 0 0 1px #ece8ee inset;
  transition: box-shadow 0.2s ease;
}
.login-card :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #ffb3c8 inset, 0 6px 18px -8px rgba(242, 92, 132, 0.45);
}

/* 移动端：隐藏左侧，仅保留表单 */
@media (max-width: 860px) {
  .login-aside {
    display: none;
  }
  .login-main {
    flex: 1 1 100%;
    min-width: 0;
  }
}

/* 尊重用户的减少动态偏好 */
@media (prefers-reduced-motion: reduce) {
  .login-aside,
  .brand,
  .aside-title,
  .feature-list,
  .aside-foot,
  .login-card {
    animation: none;
  }
  .login-glow {
    animation: none;
  }
}
</style>
