<script>
import { userStore } from './store/user.js'

export default {
  onLaunch() {
    console.log('APP onLaunch 启动')
    // 启动后若有 token 自动拉取用户信息
    const token = uni.getStorageSync('token')
    if (token) {
      userStore.fetchInfo().catch(() => {})
    }
  },
  globalData: {}
}
</script>

<style>
/* 全局基础样式：引入统一设计系统 */
@import './styles/global.css';
</style>
