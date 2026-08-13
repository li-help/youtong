<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { SwitchButton } from '@element-plus/icons-vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import { menus } from '../router/menu'
import { authApi } from '../api'

const route = useRoute()
const router = useRouter()

const nickname = computed(() => {
  try {
    return JSON.parse(localStorage.getItem('user') || '{}').nickname || ''
  } catch {
    return ''
  }
})

// 受控展开：默认展开当前路由所属分组
const openeds = ref([])
const activeGroup = computed(() => {
  const group = menus.find((m) => route.path.startsWith(m.path))
  return group ? group.path : ''
})
function syncOpened() {
  if (activeGroup.value && !openeds.value.includes(activeGroup.value)) {
    openeds.value = [activeGroup.value]
  }
}
watch(() => route.path, syncOpened, { immediate: true })

function handleClick(path) {
  if (path !== route.path) {
    router.push(path)
  }
}

async function logout() {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await authApi.logout()
  } catch {
    // 忽略登出接口错误，仍执行本地退出
  }
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  ElMessage.success('已退出登录')
  router.replace('/login')
}
</script>

<template>
  <div class="layout">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="logo">
        <span class="logo-dot"></span>
        优童成长社
      </div>
      <el-menu
        :default-active="route.path"
        :openeds="openeds"
        unique-opened
        class="menu"
        @open-change="(v) => (openeds = v)"
      >
        <el-sub-menu v-for="m in menus" :key="m.path" :index="m.path">
          <template #title>
            <el-icon><component :is="m.icon" /></el-icon>
            <span>{{ m.title }}</span>
          </template>
          <el-menu-item
            v-for="c in m.children"
            :key="c.path"
            :index="c.path"
            @click="handleClick(c.path)"
          >{{ c.title }}</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </aside>

    <!-- 主区 -->
    <div class="main">
      <header class="header">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>后台管理</el-breadcrumb-item>
          <el-breadcrumb-item>{{ route.name }}</el-breadcrumb-item>
        </el-breadcrumb>
        <div class="header-right">
          <el-avatar :size="32" style="background: var(--brand)">{{ nickname.charAt(0) || '优' }}</el-avatar>
          <span class="username">{{ nickname || '管理员' }}</span>
          <el-button text type="primary" :icon="SwitchButton" @click="logout">退出登录</el-button>
        </div>
      </header>
      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<style scoped>
.layout {
  display: flex;
  height: 100%;
}
.sidebar {
  width: 220px;
  background: var(--sidebar-bg);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
}
.logo {
  height: 64px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 20px;
  font-size: 18px;
  font-weight: 700;
  color: var(--text-heading);
  border-bottom: 1px solid var(--border);
}
.logo-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--brand);
}
.menu {
  border-right: none;
  flex: 1;
  overflow: hidden;
  scrollbar-width: none;            /* Firefox 隐藏滚动条 */
}
.menu :deep(.el-scrollbar__bar),
.menu :deep(::-webkit-scrollbar) {
  display: none;                    /* Webkit 隐藏滚动条 */
}
/* 左侧路由选中时文字加粗 */
.menu :deep(.el-menu-item.is-active) {
  font-weight: 700;
}
.menu :deep(.el-sub-menu.is-active > .el-sub-menu__title) {
  font-weight: 700;
}
.main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.header {
  height: 64px;
  background: var(--bg-white);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}
.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
}
.username {
  color: var(--text);
}
.content {
  flex: 1;
  overflow-y: auto;
  padding: 14px 18px;
}
</style>
