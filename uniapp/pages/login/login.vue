<template>
  <view class="login-page">
    <!-- 头像区域 -->
    <view class="avatar-section">
      <view class="avatar-circle">
        <text class="avatar-icon">👤</text>
      </view>
      <text class="brand-slogan">优童成长 · 陪伴每一个小宇宙</text>
    </view>

    <!-- 表单区域 -->
    <view class="form-card">
      <view class="input-item">
        <input class="input" v-model="phone" placeholder="请输入手机号" placeholder-class="ph" />
      </view>
      <view class="input-item">
        <input class="input" v-model="password" password placeholder="请输入密码" placeholder-class="ph" />
      </view>

      <button class="btn-login" :loading="loading" @click="onLogin">登 录</button>

      <!-- 微信一键登录 -->
      <button class="btn-wechat" :loading="wxLoading" @click="onWechatLogin">
        <text class="wx-icon">💬</text> 微信一键登录
      </button>

      <!-- 微信扫码登录 -->
      <button class="btn-scan" @click="openScan">
        <text class="scan-icon">📷</text> 微信扫码登录
      </button>

      <view class="form-links">
        <text class="link" @click="goRegister">还没有账号？立即注册</text>
      </view>
      
      <view class="form-bottom">
        <text class="link-small" @click="forgotPwd">忘记密码</text>
        <text class="link-small" @click="switchLogin">切换账号登录</text>
      </view>
    </view>

    <!-- 微信扫码登录弹窗 -->
    <view v-if="showScan" class="scan-mask" @click.self="closeScan">
      <view class="scan-modal">
        <text class="scan-title">微信扫码登录</text>
        <view class="scan-qr-box">
          <image v-if="qrImage" :src="qrImage" class="scan-qr" mode="aspectFit" />
          <view v-else class="scan-loading">
            <text>二维码加载中...</text>
          </view>
        </view>
        <text class="scan-tip">{{ scanTip }}</text>
        <!-- 演示用：模拟手机端确认 -->
        <button class="btn-scan-confirm" v-if="ticket" @click="simulateConfirm">我已扫码并确认</button>
        <text class="scan-close" @click="closeScan">关闭</text>
      </view>
    </view>

    <!-- 忘记密码弹窗 -->
    <view v-if="showForgot" class="scan-mask" @click.self="closeForgot">
      <view class="scan-modal">
        <text class="scan-title">重置密码</text>
        <input class="forgot-input" v-model="forgotForm.username" placeholder="账号" placeholder-class="ph" />
        <input class="forgot-input" v-model="forgotForm.oldPassword" password placeholder="原密码" placeholder-class="ph" />
        <input class="forgot-input" v-model="forgotForm.newPassword" password placeholder="新密码（至少6位）" placeholder-class="ph" />
        <button class="btn-scan-confirm" :loading="forgotLoading" @click="doReset">确认重置</button>
        <text class="scan-close" @click="closeForgot">关闭</text>
      </view>
    </view>
  </view>
</template>

<script>
import { userStore } from '../../store/user.js'
import { authApi } from '../../api/index.js'

export default {
  data() {
    return {
      phone: '',
      password: '',
      loading: false,
      wxLoading: false,
      showScan: false,
      qrImage: '',
      ticket: '',
      scanTip: '请使用微信扫一扫',
      scanTimer: null,
      showForgot: false,
      forgotForm: { username: '', oldPassword: '', newPassword: '' },
      forgotLoading: false
    }
  },
  methods: {
    goBack() {
      uni.navigateBack({ fail: () => {} })
    },
    onLogin() {
      if (!this.phone || !this.password) {
        uni.showToast({ title: '请输入手机号和密码', icon: 'none' })
        return
      }
      this.loading = true
      this.doLogin()
    },
    async doLogin() {
      try {
        await userStore.login(this.phone, this.password)
        uni.showToast({ title: '登录成功', icon: 'success' })
        setTimeout(() => {
          uni.switchTab({ url: '/pages/tabbar/home/home' })
        }, 600)
      } catch (e) {
        console.error('登录失败:', e)
        const errMsg = (e && (e.errMsg || e.msg || JSON.stringify(e))) || '未知错误'
        uni.showModal({
          title: '登录失败',
          content: `原因：${errMsg}\n\n是否以演示模式进入？`,
          success: (res) => {
            if (res.confirm) {
              userStore.token = 'demo-token'
              userStore.info = { id: 1, username: this.phone, nickname: this.phone }
              uni.setStorageSync('token', 'demo-token')
              uni.switchTab({ url: '/pages/tabbar/home/home' })
            }
          }
        })
      } finally {
        this.loading = false
      }
    },
    goRegister() {
      uni.navigateTo({ url: '/pages/register/register' })
    },
    forgotPwd() {
      this.forgotForm = { username: this.phone || '', oldPassword: '', newPassword: '' }
      this.showForgot = true
    },
    async doReset() {
      const { username, oldPassword, newPassword } = this.forgotForm
      if (!username || !oldPassword || !newPassword) {
        uni.showToast({ title: '请填写完整信息', icon: 'none' })
        return
      }
      if (newPassword.length < 6) {
        uni.showToast({ title: '新密码至少 6 位', icon: 'none' })
        return
      }
      this.forgotLoading = true
      try {
        await authApi.resetPwd(username, oldPassword, newPassword)
        uni.showToast({ title: '密码重置成功', icon: 'success' })
        this.showForgot = false
        this.password = ''
      } catch (e) {
        const msg = (e && (e.errMsg || e.msg || JSON.stringify(e))) || '重置失败'
        uni.showToast({ title: msg, icon: 'none' })
      } finally {
        this.forgotLoading = false
      }
    },
    closeForgot() {
      this.showForgot = false
    },
    switchLogin() {
      // 切换账号：清除当前登录态，回到账号密码登录
      userStore.logout()
      this.phone = ''
      this.password = ''
      uni.showToast({ title: '已退出，请登录其他账号', icon: 'none' })
    },
    onWechatLogin() {
      // #ifndef MP-WEIXIN
      uni.showToast({ title: '请在微信小程序中使用一键登录', icon: 'none' })
      return
      // #endif
      // #ifdef MP-WEIXIN
      this.wxLoading = true
      uni.login({
        success: async (res) => {
          console.log('[wechat] uni.login res:', JSON.stringify(res))
          if (!res.code) {
            this.wxLoading = false
            uni.showToast({ title: '微信登录失败，未获取到 code', icon: 'none' })
            return
          }
          try {
            const data = await authApi.wechatLogin(res.code)
            this.setLoginSuccess(data)
          } catch (e) {
            console.error('[wechat] 后端登录失败:', e)
            this.wxLoading = false
            const msg = (e && (e.errMsg || e.message || JSON.stringify(e))) || '登录失败'
            uni.showModal({
              title: '微信登录失败',
              content: msg,
              showCancel: false
            })
          }
        },
        fail: (err) => {
          console.error('[wechat] uni.login 失败:', err)
          this.wxLoading = false
          uni.showModal({
            title: '微信登录失败',
            content: (err && err.errMsg) || '调用微信登录失败',
            showCancel: false
          })
        }
      })
      // #endif
    },
    setLoginSuccess(data) {
      const token = data.token || ''
      const user = data.user || {}
      userStore.token = token
      userStore.info = user
      uni.setStorageSync('token', token)
      uni.setStorageSync('userInfo', user)
      uni.showToast({ title: '登录成功', icon: 'success' })
      setTimeout(() => {
        this.wxLoading = false
        uni.switchTab({ url: '/pages/tabbar/home/home' })
      }, 600)
    },
    // ================= 微信扫码登录 =================
    async openScan() {
      this.showScan = true
      this.qrImage = ''
      this.ticket = ''
      this.scanTip = '请使用微信扫一扫'
      try {
        const res = await authApi.scanCreate()
        this.ticket = res.ticket
        // 二维码图片地址：H5 用相对路径，其他环境用完整地址
        // #ifdef H5
        this.qrImage = `/api/auth/qrcode/${res.ticket}`
        // #endif
        // #ifndef H5
        this.qrImage = `http://${this.serverIp()}:3001/api/auth/qrcode/${res.ticket}`
        // #endif
        this.startPolling()
      } catch (e) {
        this.scanTip = '二维码生成失败，请重试'
      }
    },
    startPolling() {
      this.stopPolling()
      this.scanTimer = setInterval(async () => {
        if (!this.ticket) return
        try {
          const r = await authApi.scanCheck(this.ticket)
          const status = r.status
          if (status === 'scanned') {
            this.scanTip = '已扫码，请在手机上确认'
          } else if (status === 'confirmed') {
            this.stopPolling()
            this.setLoginSuccess(r)
            this.closeScan()
          } else if (status === 'expired' || status === 'not_found') {
            this.stopPolling()
            this.scanTip = '二维码已失效，请重新打开'
          }
        } catch (e) {
          // 忽略轮询错误
        }
      }, 1500)
    },
    stopPolling() {
      if (this.scanTimer) {
        clearInterval(this.scanTimer)
        this.scanTimer = null
      }
    },
    // 演示用：模拟手机端扫码确认
    async simulateConfirm() {
      try {
        const r = await authApi.scanConfirm(this.ticket, 'wx_demo_openid')
        this.stopPolling()
        this.setLoginSuccess(r)
        this.closeScan()
      } catch (e) {
        uni.showToast({ title: '确认失败', icon: 'none' })
      }
    },
    closeScan() {
      this.stopPolling()
      this.showScan = false
      this.qrImage = ''
      this.ticket = ''
    },
    serverIp() {
      // 与 request.js 中 SERVER_IP 保持一致
      return '127.0.0.1'
    }
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: #F5F6FA;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* 头像区域 */
.avatar-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-bottom: 44rpx;
}
.avatar-circle {
  width: 180rpx; height: 180rpx; border-radius: 50%;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border: 6rpx solid #fff;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 28rpx rgba(246,181,30,.22);
}
.avatar-icon { font-size: 82rpx; color: #fff; }
.brand-slogan {
  font-size: 29rpx; font-weight: 600;
  color: #E89B00; margin-top: 20rpx; letter-spacing: 1rpx;
}

/* 表单卡片 */
.form-card {
  width: calc(100% - 60rpx);
  max-width: 660rpx;
  background: #fff;
  border-radius: 28rpx;
  padding: 52rpx 44rpx 48rpx;
  box-shadow: 0 8rpx 32rpx rgba(0,0,0,.06);
}
.input-item {
  background: #F5F6FA;
  border: 2rpx solid #E8E8E8;
  border-radius: 18rpx;
  padding: 28rpx 32rpx;
  margin-bottom: 28rpx;
}
.input { font-size: 32rpx; color: #2D2D2D; }
.ph { color: #bbb; }

.btn-login {
  margin-top: 32rpx;
  height: 96rpx; line-height: 96rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border-radius: 48rpx;
  font-size: 35rpx; font-weight: bold; color: #fff;
  border: none;
  box-shadow: 0 6rpx 20rpx rgba(246,181,30,.25);
}

.form-links { text-align: center; margin-top: 28rpx; }
.link { color: #E89B00; font-size: 28rpx; }

.form-bottom {
  display: flex; justify-content: space-between;
  margin-top: 28rpx; padding-top: 22rpx;
  border-top: 2rpx solid #F5F6FA;
}
.link-small { color: #999; font-size: 26rpx; }

/* 微信一键登录按钮 */
.btn-wechat {
  margin-top: 18rpx;
  height: 96rpx; line-height: 96rpx;
  background: #07C160; border-radius: 48rpx;
  font-size: 34rpx; font-weight: bold; color: #fff;
  border: none;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(7,193,96,.20);
}
.wx-icon { font-size: 36rpx; margin-right: 10rpx; }

/* 微信扫码登录按钮 */
.btn-scan {
  margin-top: 14rpx;
  height: 96rpx; line-height: 96rpx;
  background: #fff; border: 2rpx solid #07C160;
  border-radius: 48rpx;
  font-size: 34rpx; font-weight: bold; color: #07C160;
  display: flex; align-items: center; justify-content: center;
}
.scan-icon { font-size: 36rpx; margin-right: 10rpx; }

/* 扫码弹窗 */
.scan-mask {
  position: fixed; inset: 0;
  background: rgba(0,0,0,.5);
  display: flex; align-items: center; justify-content: center; z-index: 999;
}
.scan-modal {
  width: 560rpx; background: #fff; border-radius: 24rpx;
  padding: 38rpx 30rpx;
  display: flex; flex-direction: column; align-items: center;
}
.scan-title { font-size: 33rpx; font-weight: bold; color: #2D2D2D; margin-bottom: 22rpx; }
.scan-qr-box {
  width: 360rpx; height: 360rpx; background: #f5f5f5;
  border-radius: 16rpx;
  display: flex; align-items: center; justify-content: center; overflow: hidden;
}
.scan-qr { width: 360rpx; height: 360rpx; }
.scan-loading { font-size: 26rpx; color: #999; }
.scan-tip { font-size: 26rpx; color: #888; margin-top: 22rpx; text-align: center; }
.btn-scan-confirm {
  margin-top: 22rpx; width: 100%;
  height: 78rpx; line-height: 78rpx;
  background: #07C160; border-radius: 39rpx;
  font-size: 29rpx; color: #fff; border: none;
}
.scan-close { margin-top: 22rpx; font-size: 27rpx; color: #bbb; }

.forgot-input {
  width: 100%;
  background: #F5F6FA;
  border: 2rpx solid #E8E8E8;
  border-radius: 16rpx;
  padding: 22rpx 26rpx;
  margin-bottom: 18rpx;
  font-size: 28rpx;
  color: #2D2D2D;
  text-align: left;
}
.ph { color: #bbb; }
</style>
