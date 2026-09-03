<template>
  <view class="chat-page">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">{{ storeName || '门店客服' }}</text>
      </view>
    </view>

    <!-- 会话状态条 -->
    <view class="service-bar" :class="{ 'bar-human': sessionType === 2 }">
      <view class="bar-left">
        <text class="bar-dot"></text>
        <text class="bar-mode">{{ sessionType === 2 ? '门店人工客服服务中' : 'AI 智能助手接待中' }}</text>
      </view>
      <button v-if="sessionType === 1" class="transfer-btn" @click="handleTransfer">
        👨‍💼 转门店人工
      </button>
      <text v-else class="cs-name">{{ csInfo ? csInfo.name : '门店客服' }}</text>
    </view>

    <scroll-view scroll-y class="scroll" :scroll-into-view="scrollTo" :scroll-with-animation="true">
      <view
        v-for="(m, i) in messages"
        :key="m.clientMsgId || i"
        :id="'msg-' + i"
        class="msg-row-wrap"
      >
        <view v-if="m.senderType === 4 || m.type === 'transfer_notice'" class="system-row">
          <text class="system-text">{{ m.content }}</text>
        </view>

        <view v-else class="msg-row" :class="m.senderType === 1 ? 'right' : 'left'">
          <view class="msg-avatar">
            <text v-if="m.senderType === 3">🤖</text>
            <text v-else-if="m.senderType === 2">👨‍💼</text>
            <text v-else>👶</text>
          </view>
          <view class="bubble-container">
            <view class="bubble" :class="m.senderType === 1 ? 'bubble-user' : (m.senderType === 2 ? 'bubble-cs' : 'bubble-bot')">
              <text class="bubble-text">{{ m.content }}</text>
            </view>
            <view v-if="m.senderType === 1 && m.status !== 'success'" class="msg-status">
              <text v-if="m.status === 'sending'" class="status-loading">⏳</text>
              <text v-if="m.status === 'fail'" class="status-fail" @click="retryMessage(m)">⚠️ 重发</text>
            </view>
          </view>
        </view>
      </view>

      <view v-if="loading" class="msg-row left">
        <view class="msg-avatar">🤖</view>
        <view class="bubble bubble-bot">
          <text class="bubble-text">正在思考并查询知识库...</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>

    <!-- 满意度评价条 -->
    <view v-if="showRating" class="rating-bar">
      <text class="rating-label">请为本次门店服务评分：</text>
      <view class="rating-stars">
        <text v-for="n in 5" :key="n" class="star" @click="submitRating(n)">⭐</text>
      </view>
      <text class="rating-skip" @click="showRating = false">跳过</text>
    </view>

    <view class="input-bar">
      <input
        class="chat-input"
        v-model="inputText"
        :placeholder="sessionType === 2 ? '向门店客服发送消息...' : '输入育儿问题，或输入“转人工”...'"
        placeholder-class="ph"
        @confirm="send"
      />
      <button class="send-btn" :disabled="loading" @click="send">发送</button>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { aiApi, imApi } from '@/api/index.js'
import { imChat } from '@/utils/imChatService.js'
import { refreshUnreadBadge } from '@/utils/badge.js'

const messages = ref([])
const inputText = ref('')
const loading = ref(false)
const scrollTo = ref('')
const sessionType = ref(1) // 1-AI, 2-人工
const sessionId = ref(null)
const csInfo = ref(null)
const storeId = ref(0)
const storeName = ref('')
const showRating = ref(false)
const rated = ref(false)
let unsubscribeWs = null

onMounted(async () => {
  const pages = getCurrentPages()
  const options = pages[pages.length - 1].options || {}
  storeId.value = Number(options.storeId) || 0
  if (options.name) {
    try { storeName.value = decodeURIComponent(options.name) } catch (e) { storeName.value = '' }
  }
  messages.value = [{
    senderType: 3,
    content: storeName.value
      ? `您好～我是${storeName.value}的客服，可为您咨询该门店的课程、活动与预约事宜，需要人工服务请点击上方按钮。`
      : '您好～我是本店客服，可为您咨询课程、活动与预约事宜，需要人工服务请点击上方按钮。',
    status: 'success'
  }]
  await initSession()
  initWs()
})

onUnmounted(() => {
  if (unsubscribeWs) unsubscribeWs()
  refreshUnreadBadge()
})

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/tabbar/home/home' }) })
}

async function initSession() {
  const token = uni.getStorageSync('token')
  if (!token) {
    uni.showToast({ title: '请先登录后咨询', icon: 'none' })
    return
  }
  try {
    const session = await imApi.initSession(storeId.value)
    if (session && session.id) {
      sessionId.value = session.id
      sessionType.value = session.sessionType || 1
      const history = await imApi.history(session.id, 1, 30)
      if (Array.isArray(history) && history.length > 0) {
        messages.value = history.map((h) => ({ ...h, status: 'success' }))
        scrollBottom()
      }
    }
  } catch (e) {}
}

function initWs() {
  imChat.connect()
  unsubscribeWs = imChat.onMessage((data) => {
    // 只处理当前店铺会话的消息
    if (data.type === 'chat' && data.message) {
      const msg = data.message
      if (msg.sessionId !== sessionId.value) return
      if (msg.senderType !== 1) {
        messages.value.push({ ...msg, status: 'success' })
        scrollBottom()
      }
    } else if (data.type === 'transfer') {
      if (data.sessionId && data.sessionId !== sessionId.value) return
      sessionType.value = 2
      if (data.message) {
        messages.value.push(data.message)
        scrollBottom()
      }
    } else if (data.type === 'session_close') {
      if (data.sessionId && data.sessionId !== sessionId.value) return
      sessionType.value = 1
      csInfo.value = null
      showRating.value = !rated.value
      if (data.message) {
        messages.value.push(data.message)
        scrollBottom()
      }
    }
  })
}

// 提交满意度评分
async function submitRating(score) {
  try {
    await imApi.rate(sessionId.value, score)
    rated.value = true
    showRating.value = false
    messages.value.push({
      senderType: 4,
      type: 'rate_notice',
      content: `已提交评价：${score} 星，感谢您的反馈！`,
      status: 'success'
    })
    scrollBottom()
  } catch (e) {
    uni.showToast({ title: '评价失败，请重试', icon: 'none' })
  }
}

async function handleTransfer() {
  const token = uni.getStorageSync('token')
  if (!token) {
    uni.showToast({ title: '请先登录后再转接人工', icon: 'none' })
    return
  }
  uni.showLoading({ title: '正在转接门店客服...' })
  try {
    const res = await imApi.transfer(sessionId.value)
    sessionType.value = 2
    if (res && res.cs) csInfo.value = res.cs
    if (res && res.notice) {
      messages.value.push({
        senderType: 4,
        type: 'transfer_notice',
        content: res.notice,
        status: 'success'
      })
      scrollBottom()
    }
    uni.showToast({ title: '已接通门店客服', icon: 'success' })
  } catch (e) {
    uni.showToast({ title: '转接失败，请稍后重试', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function send() {
  const text = inputText.value.trim()
  if (!text || loading.value) return

  const clientMsgId = 'u_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7)
  const userMsg = { clientMsgId, senderType: 1, content: text, status: 'sending' }
  messages.value.push(userMsg)
  inputText.value = ''
  scrollBottom()

  // 人工客服模式：WebSocket 实时收发（后端自动路由给本店客服）
  if (sessionType.value === 2) {
    imChat.sendMessage({
      type: 'chat',
      sessionId: sessionId.value,
      clientMsgId,
      senderType: 1,
      receiverId: 0,
      content: text
    }, (updated) => { userMsg.status = updated.status })
    return
  }

  // AI 客服模式：FAQ 匹配 + 转人工检测
  loading.value = true
  aiApi.serviceChat({
    message: text,
    sessionId: sessionId.value,
    clientMsgId
  }).then((res) => {
    userMsg.status = 'success'
    if (res) {
      if (res.needTransfer || res.type === 'transfer') {
        sessionType.value = 2
      }
      messages.value.push({
        senderType: res.type === 'faq' ? 3 : (res.type === 'transfer' ? 4 : 3),
        content: res.content || '我已收到您的问题。',
        status: 'success'
      })
      scrollBottom()
    }
  }).catch(() => {
    userMsg.status = 'fail'
    messages.value.push({
      senderType: 3,
      content: '网络开小差了，请点击气泡旁的重试，或转接门店人工客服。',
      status: 'success'
    })
    scrollBottom()
  }).finally(() => {
    loading.value = false
  })
}

function retryMessage(msg) {
  msg.status = 'sending'
  if (sessionType.value === 2) {
    imChat.retry({
      type: 'chat',
      sessionId: sessionId.value,
      clientMsgId: msg.clientMsgId,
      senderType: 1,
      receiverId: 0,
      content: msg.content
    }, (u) => { msg.status = u.status })
  }
}

function scrollBottom() {
  nextTick(() => {
    scrollTo.value = 'msg-' + (messages.value.length - 1)
  })
}
</script>

<style scoped>
.chat-page {
  min-height: 100vh;
  background-color: var(--c-bg-page);
  display: flex;
  flex-direction: column;
}

.service-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: var(--space-2) var(--space-3) 0;
  padding: 12rpx 24rpx;
  background: #FFFFFF;
  border-radius: var(--radius-full);
  box-shadow: var(--shadow-sm);
  border: 1rpx solid var(--c-border);
}
.service-bar.bar-human { background: #F0F9FF; border-color: #BAE6FD; }
.bar-left { display: flex; align-items: center; gap: 12rpx; }
.bar-dot {
  width: 14rpx; height: 14rpx; border-radius: 50%;
  background: var(--c-success);
  box-shadow: 0 0 8rpx rgba(16, 185, 129, 0.6);
}
.bar-mode { font-size: 24rpx; color: var(--c-text-main); font-weight: 500; }
.transfer-btn {
  font-size: 22rpx; color: var(--c-primary);
  background: var(--c-primary-soft);
  border-radius: var(--radius-full);
  padding: 6rpx 20rpx; font-weight: 600; line-height: 1.4;
  margin: 0; border: 1rpx solid rgba(255, 122, 24, 0.3);
}
.transfer-btn::after { border: none; }
.cs-name { font-size: 24rpx; color: var(--c-info); font-weight: 600; }

.scroll {
  flex: 1;
  height: calc(100vh - 88rpx - 80rpx - 110rpx - var(--window-bottom));
  padding: var(--space-2) var(--space-3);
  box-sizing: border-box;
}

.msg-row-wrap { width: 100%; margin-bottom: var(--space-3); }
.msg-row { display: flex; align-items: flex-start; gap: 12rpx; }
.msg-row.right { flex-direction: row-reverse; }

.msg-avatar {
  width: 60rpx; height: 60rpx; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 30rpx; flex-shrink: 0;
  box-shadow: var(--shadow-sm);
  background: #FFFFFF; border: 1rpx solid var(--c-border);
}

.bubble-container { max-width: 72%; display: flex; align-items: flex-end; gap: 8rpx; }
.msg-row.right .bubble-container { flex-direction: row-reverse; }

.bubble { padding: 18rpx 26rpx; font-size: 28rpx; line-height: 1.5; word-break: break-word; }
.bubble-bot {
  background: #FFFFFF; color: var(--c-text-title);
  border-radius: var(--radius-md) var(--radius-md) var(--radius-md) 4rpx;
  box-shadow: var(--shadow-card); border: 1rpx solid var(--c-border);
}
.bubble-cs {
  background: #F0F9FF; border: 1rpx solid #BAE6FD; color: #0369A1;
  border-radius: var(--radius-md) var(--radius-md) var(--radius-md) 4rpx;
}
.bubble-user {
  background: var(--c-primary-gradient); color: #FFFFFF;
  border-radius: var(--radius-md) var(--radius-md) 4rpx var(--radius-md);
  box-shadow: var(--shadow-glow);
}
.bubble-user .bubble-text { color: #FFFFFF; }

.msg-status { font-size: 20rpx; margin-bottom: 6rpx; }
.status-loading { color: var(--c-text-muted); }
.status-fail { color: var(--c-danger); font-weight: 600; }

.system-row { width: 100%; text-align: center; padding: 8rpx 0; }
.system-text {
  font-size: 20rpx; background: #E2E8F0; color: var(--c-text-main);
  padding: 6rpx 20rpx; border-radius: var(--radius-full);
}

.rating-bar {
  display: flex; align-items: center; gap: 12rpx;
  padding: 14rpx var(--space-3);
  background: #FFF9F2; border-top: 1rpx solid #FFE7D1;
}
.rating-label { font-size: 24rpx; color: var(--c-text-main); }
.rating-stars { display: flex; gap: 8rpx; flex: 1; }
.star { font-size: 36rpx; }
.rating-skip { font-size: 22rpx; color: var(--c-text-muted); padding: 0 10rpx; }

.input-bar {
  position: fixed;
  bottom: 0;
  left: 0; right: 0;
  display: flex; align-items: center; gap: 12rpx;
  padding: 14rpx var(--space-3);
  padding-bottom: calc(14rpx + env(safe-area-inset-bottom));
  background: #FFFFFF;
  border-top: 1rpx solid var(--c-border);
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.04);
}
.chat-input {
  flex: 1; height: 72rpx;
  background: var(--c-bg-input);
  border-radius: var(--radius-full);
  padding: 0 24rpx; font-size: 28rpx; color: var(--c-text-title);
}
.ph { color: var(--c-text-placeholder); }
.send-btn {
  width: 116rpx; height: 72rpx; line-height: 72rpx;
  background: var(--c-primary-gradient);
  border-radius: var(--radius-full);
  font-size: 26rpx; font-weight: 600; color: #FFFFFF;
  border: none; padding: 0;
  box-shadow: var(--shadow-glow);
}
.send-btn::after { border: none; }
.bottom-space { height: 30rpx; }
</style>
