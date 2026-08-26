<template>
  <view class="ai-page">
    <!-- 顶部标题与客服状态切换栏 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">优童智能客服</text>
      </view>
    </view>

    <!-- 会话状态条 -->
    <view class="service-bar" :class="{ 'bar-human': sessionType === 2 }">
      <view class="bar-left">
        <text class="bar-dot"></text>
        <text class="bar-mode">{{ sessionType === 2 ? '人工客服在线服务中' : 'AI 智能助手接待中' }}</text>
      </view>
      <button v-if="sessionType === 1" class="transfer-btn" @click="handleTransfer">
        👨‍💼 转人工客服
      </button>
      <text v-else class="cs-name">{{ csInfo ? csInfo.name : '人工老师' }}</text>
    </view>

    <scroll-view scroll-y class="scroll" :scroll-into-view="scrollTo" :scroll-with-animation="true">
      <!-- 机器人欢迎区 -->
      <view class="hero" v-if="messages.length <= 1">
        <view class="bot-avatar">
          <text class="bot-emoji">🤖</text>
        </view>
        <text class="hero-title">优童智能助手</text>
        <text class="hero-sub">支持 24 小时育儿咨询、课程活动解答与业务常见问题查询</text>

        <!-- 热门 FAQ 快捷提问气泡 -->
        <view class="faq-box" v-if="hotFaqs.length > 0">
          <view class="faq-title">💡 常见问题推荐：</view>
          <view class="faq-tags">
            <text class="faq-tag" v-for="f in hotFaqs" :key="f.id" @click="askFaq(f.question)">
              {{ f.question }}
            </text>
          </view>
        </view>
      </view>

      <!-- 对话消息列表 -->
      <view
        v-for="(m, i) in messages"
        :key="m.clientMsgId || i"
        :id="'msg-' + i"
        class="msg-row-wrap"
      >
        <!-- 系统通知提示条 -->
        <view v-if="m.senderType === 4 || m.type === 'transfer_notice'" class="system-row">
          <text class="system-text">{{ m.content }}</text>
        </view>

        <!-- 对话气泡（用户 / AI / 人工客服） -->
        <view
          v-else
          class="msg-row"
          :class="m.senderType === 1 ? 'right' : 'left'"
        >
          <!-- 头像 -->
          <view class="msg-avatar" :class="avatarClass(m)">
            <text v-if="m.senderType === 3">🤖</text>
            <text v-else-if="m.senderType === 2">👨‍💼</text>
            <text v-else>👶</text>
          </view>

          <!-- 气泡主体 -->
          <view class="bubble-container">
            <view class="bubble" :class="bubbleClass(m)">
              <text class="bubble-text">{{ m.content }}</text>
            </view>

            <!-- 用户消息发送状态（发送中 / 发送失败重试） -->
            <view v-if="m.senderType === 1" class="msg-status">
              <text v-if="m.status === 'sending'" class="status-loading">⏳</text>
              <text v-if="m.status === 'fail'" class="status-fail" @click="retryMessage(m)">⚠️ 重发</text>
            </view>
          </view>
        </view>
      </view>

      <!-- AI 思考中气泡 -->
      <view v-if="loading" class="msg-row left">
        <view class="msg-avatar avatar-bot">🤖</view>
        <view class="bubble bubble-bot">
          <text class="bubble-text">正在思考并查询知识库...</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>

    <!-- 底部输入栏 -->
    <view class="input-bar">
      <input
        class="chat-input"
        v-model="inputText"
        :placeholder="sessionType === 2 ? '向人工客服发送消息...' : '输入育儿问题，或输入“转人工”...'"
        placeholder-class="ph"
        @confirm="send"
      />
      <button class="send-btn" :disabled="loading" @click="send">发送</button>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { aiApi, faqApi, imApi } from '@/api/index.js'
import { imChat } from '@/utils/imChatService.js'

const messages = ref([
  {
    senderType: 3,
    content: '家长您好～我是优童 AI 智能客服，您可以咨询任何育儿知识、入园指南与课程服务，也可以随时点击右上角转接人工客服哦！',
    status: 'success'
  }
])

const inputText = ref('')
const loading = ref(false)
const scrollTo = ref('')
const sessionType = ref(1) // 1-AI, 2-人工
const sessionId = ref(null)
const csInfo = ref(null)
const hotFaqs = ref([])
let unsubscribeWs = null

onMounted(async () => {
  await loadHotFaqs()
  await initSession()
  initWs()
})

onShow(() => {
  imChat.connect()
})

onUnmounted(() => {
  if (unsubscribeWs) unsubscribeWs()
})

async function loadHotFaqs() {
  try {
    const res = await faqApi.hot(4)
    hotFaqs.value = res || []
  } catch (e) {}
}

async function initSession() {
  const token = uni.getStorageSync('token')
  if (!token) return

  try {
    const session = await imApi.initSession(0)
    if (session && session.id) {
      sessionId.value = session.id
      sessionType.value = session.sessionType || 1

      // 加载历史聊天记录
      const history = await imApi.history(session.id, 1, 30)
      if (Array.isArray(history) && history.length > 0) {
        messages.value = history.map(h => ({
          ...h,
          status: 'success'
        }))
        scrollBottom()
      }
    }
  } catch (e) {}
}

function initWs() {
  imChat.connect()
  unsubscribeWs = imChat.onMessage((data) => {
    // 接收实时推送的聊天消息
    if (data.type === 'chat' && data.message) {
      const msg = data.message
      if (msg.senderType !== 1) {
        messages.value.push({
          ...msg,
          status: 'success'
        })
        scrollBottom()
      }
    } else if (data.type === 'transfer') {
      sessionType.value = 2
      if (data.message) {
        messages.value.push(data.message)
        scrollBottom()
      }
    }
  })
}

function askFaq(q) {
  inputText.value = q
  send()
}

async function handleTransfer() {
  const token = uni.getStorageSync('token')
  if (!token) {
    uni.showToast({ title: '请先登录后再转接人工', icon: 'none' })
    return
  }

  uni.showLoading({ title: '正在转接人工...' })
  try {
    const res = await imApi.transfer(sessionId.value)
    sessionType.value = 2
    if (res && res.notice) {
      messages.value.push({
        senderType: 4,
        type: 'transfer_notice',
        content: res.notice,
        status: 'success'
      })
      scrollBottom()
    }
    uni.showToast({ title: '已接通人工客服', icon: 'success' })
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
  const userMsg = {
    clientMsgId,
    senderType: 1,
    content: text,
    status: 'sending'
  }

  messages.value.push(userMsg)
  inputText.value = ''
  scrollBottom()

  // 如果当前是人工客服模式，走 WebSocket 实时收发
  if (sessionType.value === 2) {
    imChat.sendMessage({
      type: 'chat',
      sessionId: sessionId.value,
      clientMsgId,
      senderType: 1,
      receiverId: 0,
      content: text
    }, (updated) => {
      userMsg.status = updated.status
    })
    return
  }

  // AI 客服模式：调用 /api/ai/service-chat（后端含 FAQ 匹配、多轮与转人工检测）
  loading.value = true
  aiApi.serviceChat({
    message: text,
    sessionId: sessionId.value,
    clientMsgId
  }).then(res => {
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
      content: '网络开小差了，请点击气泡旁的重试，或尝试转接人工客服。',
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
  } else {
    aiApi.serviceChat({
      message: msg.content,
      sessionId: sessionId.value,
      clientMsgId: msg.clientMsgId
    }).then(res => {
      msg.status = 'success'
      if (res && res.content) {
        messages.value.push({ senderType: 3, content: res.content, status: 'success' })
        scrollBottom()
      }
    }).catch(() => { msg.status = 'fail' })
  }
}

function avatarClass(m) {
  if (m.senderType === 3) return 'avatar-bot'
  if (m.senderType === 2) return 'avatar-cs'
  return 'avatar-user'
}

function bubbleClass(m) {
  if (m.senderType === 1) return 'bubble-user'
  if (m.senderType === 2) return 'bubble-cs'
  return 'bubble-bot'
}

function scrollBottom() {
  nextTick(() => {
    scrollTo.value = 'msg-' + (messages.value.length - 1)
  })
}
</script>

<style scoped>
.ai-page {
  min-height: 100vh;
  background-color: var(--c-bg-page);
  display: flex;
  flex-direction: column;
}

/* 顶部服务状态胶囊条 */
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
.service-bar.bar-human {
  background: #F0F9FF;
  border-color: #BAE6FD;
}
.bar-left {
  display: flex;
  align-items: center;
  gap: 12rpx;
}
.bar-dot {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: var(--c-success);
  box-shadow: 0 0 8rpx rgba(16, 185, 129, 0.6);
}
.bar-mode {
  font-size: 24rpx;
  color: var(--c-text-main);
  font-weight: 500;
}
.transfer-btn {
  font-size: 22rpx;
  color: var(--c-primary);
  background: var(--c-primary-soft);
  border-radius: var(--radius-full);
  padding: 6rpx 20rpx;
  font-weight: 600;
  line-height: 1.4;
  margin: 0;
  border: 1rpx solid rgba(255, 122, 24, 0.3);
}
.transfer-btn::after { border: none; }
.cs-name { font-size: 24rpx; color: var(--c-info); font-weight: 600; }

.scroll {
  flex: 1;
  height: calc(100vh - 88rpx - 80rpx - 110rpx - var(--window-bottom));
  padding: var(--space-2) var(--space-3);
  box-sizing: border-box;
}

/* 紧凑型欢迎卡片 */
.hero {
  background: #FFFFFF;
  border-radius: var(--radius-lg);
  padding: var(--space-3) var(--space-4);
  margin-bottom: var(--space-3);
  box-shadow: var(--shadow-card);
  border: 1rpx solid var(--c-border);
  text-align: center;
}
.bot-avatar {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  margin: 0 auto var(--space-1);
  background: var(--c-primary-gradient);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-glow);
}
.bot-emoji { font-size: 48rpx; }
.hero-title { font-size: 30rpx; font-weight: 700; color: var(--c-text-title); display: block; }
.hero-sub { font-size: 22rpx; color: var(--c-text-muted); margin-top: 6rpx; display: block; line-height: 1.4; }

/* FAQ 快捷点选 */
.faq-box { margin-top: var(--space-2); padding-top: var(--space-2); border-top: 1rpx solid var(--c-line); text-align: left; }
.faq-title { font-size: 22rpx; font-weight: 600; color: var(--c-text-main); margin-bottom: 10rpx; }
.faq-tags { display: flex; flex-wrap: wrap; gap: 10rpx; }
.faq-tag {
  font-size: 22rpx;
  color: var(--c-primary);
  background: var(--c-primary-soft);
  padding: 8rpx 18rpx;
  border-radius: var(--radius-full);
  border: 1rpx solid rgba(255, 122, 24, 0.2);
}

/* 消息流与气泡 */
.msg-row-wrap { width: 100%; margin-bottom: var(--space-3); }
.msg-row { display: flex; align-items: flex-start; gap: 12rpx; }
.msg-row.right { flex-direction: row-reverse; }

.msg-avatar {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30rpx;
  flex-shrink: 0;
  box-shadow: var(--shadow-sm);
  background: #FFFFFF;
  border: 1rpx solid var(--c-border);
}

.bubble-container {
  max-width: 72%;
  display: flex;
  align-items: flex-end;
  gap: 8rpx;
}
.msg-row.right .bubble-container { flex-direction: row-reverse; }

.bubble {
  padding: 18rpx 26rpx;
  font-size: 28rpx;
  line-height: 1.5;
  word-break: break-word;
}
.bubble-bot {
  background: #FFFFFF;
  color: var(--c-text-title);
  border-radius: var(--radius-md) var(--radius-md) var(--radius-md) 4rpx;
  box-shadow: var(--shadow-card);
  border: 1rpx solid var(--c-border);
}
.bubble-cs {
  background: #F0F9FF;
  border: 1rpx solid #BAE6FD;
  color: #0369A1;
  border-radius: var(--radius-md) var(--radius-md) var(--radius-md) 4rpx;
}
.bubble-user {
  background: var(--c-primary-gradient);
  color: #FFFFFF;
  border-radius: var(--radius-md) var(--radius-md) 4rpx var(--radius-md);
  box-shadow: var(--shadow-glow);
}
.bubble-user .bubble-text { color: #FFFFFF; }

.msg-status { font-size: 20rpx; margin-bottom: 6rpx; }
.status-loading { color: var(--c-text-muted); }
.status-fail { color: var(--c-danger); font-weight: 600; }

/* 系统通知行 */
.system-row { width: 100%; text-align: center; padding: 8rpx 0; }
.system-text {
  font-size: 20rpx;
  background: #E2E8F0;
  color: var(--c-text-main);
  padding: 6rpx 20rpx;
  border-radius: var(--radius-full);
}

/* 输入栏 */
.input-bar {
  position: fixed;
  bottom: var(--window-bottom);
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 14rpx var(--space-3);
  padding-bottom: calc(14rpx + env(safe-area-inset-bottom));
  background: #FFFFFF;
  border-top: 1rpx solid var(--c-border);
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.04);
}
.chat-input {
  flex: 1;
  height: 72rpx;
  background: var(--c-bg-input);
  border-radius: var(--radius-full);
  padding: 0 24rpx;
  font-size: 28rpx;
  color: var(--c-text-title);
}
.ph { color: var(--c-text-placeholder); }
.send-btn {
  width: 116rpx;
  height: 72rpx;
  line-height: 72rpx;
  background: var(--c-primary-gradient);
  border-radius: var(--radius-full);
  font-size: 26rpx;
  font-weight: 600;
  color: #FFFFFF;
  border: none;
  padding: 0;
  box-shadow: var(--shadow-glow);
}
.send-btn::after { border: none; }
.bottom-space { height: 30rpx; }
</style>
