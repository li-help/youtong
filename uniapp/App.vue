<script>
import { userStore } from './store/user.js'

export default {
  onLaunch() {
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
/* 全局基础样式 */
page {
  background-color: #FFF8E1;
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Helvetica, sans-serif;
  color: #333333;
  font-size: 28rpx;
  box-sizing: border-box;
}
view, text, image, scroll-view, navigator {
  box-sizing: border-box;
}
.container {
  padding: 24rpx;
}
.btn-primary {
  background: linear-gradient(90deg, #FFC107, #FFA000);
  color: #fff;
  border-radius: 48rpx;
  font-size: 32rpx;
}
.flex-row { display: flex; flex-direction: row; }
.flex-col { display: flex; flex-direction: column; }
.flex-center { display: flex; align-items: center; justify-content: center; }
.flex-between { display: flex; align-items: center; justify-content: space-between; }
.card {
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(255, 160, 0, 0.08);
}
.section-title {
  font-size: 34rpx;
  font-weight: bold;
  color: #333;
  margin: 16rpx 0;
  display: flex;
  align-items: center;
}
.section-title::before {
  content: '';
  display: inline-block;
  width: 8rpx;
  height: 32rpx;
  background: #FFA000;
  border-radius: 4rpx;
  margin-right: 16rpx;
}
.text-muted { color: #999; }
.price { color: #FF7043; font-weight: bold; }
</style>
