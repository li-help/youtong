<template>
  <view class="ai-page">
    <!-- 顶部标题 -->
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__title">AI 智能助手</text>
      </view>
    </view>

    <scroll-view scroll-y class="scroll" :scroll-into-view="scrollTo">
      <!-- 机器人欢迎区 -->
      <view class="hero">
        <view class="bot-avatar">
          <text class="bot-emoji">🤖</text>
        </view>
        <text class="hero-title">AI智能体</text>
        <text class="hero-sub">嗨～我是你的育儿小助手，有什么可以帮你的吗？</text>
      </view>

      <!-- 对话列表 -->
      <view v-for="(m, i) in messages" :key="i" :id="'msg-' + i" class="msg-row" :class="m.role === 'user' ? 'right' : 'left'">
        <view v-if="m.role === 'bot'" class="msg-avatar">🤖</view>
        <view class="bubble" :class="m.role === 'user' ? 'bubble-user' : 'bubble-bot'">
          <text class="bubble-text">{{ m.content }}</text>
        </view>
      </view>

      <view v-if="loading" class="msg-row left">
        <view class="msg-avatar">🤖</view>
        <view class="bubble bubble-bot">
          <text class="bubble-text">正在思考...</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>

    <!-- 输入栏 -->
    <view class="input-bar">
      <input class="chat-input" v-model="inputText" placeholder="输入宝宝年龄、兴趣或问题..." placeholder-class="ph" @confirm="send" />
      <button class="send-btn" @click="send">发送</button>
    </view>
  </view>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import { aiApi } from '@/api/index.js'

const messages = ref([
  { role: 'bot', content: '你好呀～我可以根据宝宝的年龄和兴趣，为你推荐合适的课程和活动哦！' }
])
const inputText = ref('')
const loading = ref(false)
const scrollTo = ref('')

function send() {
  const text = inputText.value.trim()
  if (!text || loading.value) return
  messages.value.push({ role: 'user', content: text })
  inputText.value = ''
  scrollBottom()

  loading.value = true
  const history = messages.value.map(m => ({ role: m.role === 'user' ? 'user' : 'assistant', content: m.content }))
  aiApi.chat(history)
    .then(res => {
      const reply = (res && res.content) ? res.content : '抱歉，我暂时无法回答，请稍后再试～'
      messages.value.push({ role: 'bot', content: reply })
      scrollBottom()
    })
    .catch(() => {
      messages.value.push({ role: 'bot', content: '网络有点忙，请稍后再问我哦～' })
      scrollBottom()
    })
    .finally(() => {
      loading.value = false
    })
}

function scrollBottom() {
  nextTick(() => {
    scrollTo.value = 'msg-' + (messages.value.length - 1)
  })
}
</script>

<style scoped>
.ai-page { min-height: 100vh; background: #F5F6FA; padding-bottom: var(--window-bottom); }
.scroll { height: calc(100vh - 88rpx - 110rpx - var(--window-bottom)); }

/* 机器人欢迎区 */
.hero { padding: 36rpx 32rpx 24rpx; text-align: center; }
.bot-avatar {
  width: 120rpx; height: 120rpx; border-radius: 50%;
  margin: 0 auto 18rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8rpx 28rpx rgba(246,181,30,.25);
}
.bot-emoji { font-size: 60rpx; }
.hero-title { font-size: 34rpx; font-weight: bold; color: #2D2D2D; display: block; }
.hero-sub { font-size: 26rpx; color: #888; margin-top: 10rpx; display: block; padding: 0 40rpx; line-height: 1.6; }

/* 消息 */
.msg-row { display: flex; align-items: flex-start; padding: 16rpx 32rpx; gap: 12rpx; }
.msg-row.right { flex-direction: row-reverse; }
.msg-avatar {
  width: 56rpx; height: 56rpx; border-radius: 50%;
  background: #fff; display: flex; align-items: center; justify-content: center;
  font-size: 28rpx; flex-shrink: 0;
  box-shadow: 0 3rpx 12rpx rgba(0,0,0,.06);
}
.bubble { max-width: 72%; padding: 20rpx 26rpx; border-radius: 20rpx; box-shadow: 0 3rpx 14rpx rgba(0,0,0,.06); }
.bubble-bot { background: #fff; border-radius: 6rpx 20rpx 20rpx 20rpx; }
.bubble-user { background: linear-gradient(135deg, #FF9F2E, #F6B51E); border-radius: 20rpx 6rpx 20rpx 20rpx; }
.bubble-user .bubble-text { color: #fff; }
.bubble-text { font-size: 28rpx; color: #2D2D2D; line-height: 1.5; }

/* 输入栏 */
.input-bar {
  position: fixed; bottom: var(--window-bottom); left: 0; right: 0;
  display: flex; align-items: center; gap: 16rpx;
  padding: 16rpx 32rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  border-top: 2rpx solid #EEEFF3;
  box-shadow: 0 -4rpx 18rpx rgba(0,0,0,.04);
}
.chat-input {
  flex: 1; background: #F5F6FA; border-radius: 36rpx;
  padding: 18rpx 28rpx; font-size: 28rpx; color: #2D2D2D;
}
.ph { color: #bbb; }
.send-btn {
  width: 128rpx; height: 72rpx; line-height: 72rpx;
  background: linear-gradient(135deg, #FF9F2E, #F6B51E);
  border-radius: 36rpx; font-size: 28rpx; font-weight: 600;
  color: #fff; border: none; padding: 0;
  box-shadow: 0 6rpx 18rpx rgba(246,181,30,.25);
}

.bottom-space { height: 30rpx; }
</style>
