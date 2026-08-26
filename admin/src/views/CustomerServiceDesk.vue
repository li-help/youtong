<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { imApi, faqApi } from '../api'
import { ElMessage } from 'element-plus'

const sessions = ref([])
const activeSession = ref(null)
const messages = ref([])
const loading = ref(false)
const inputContent = ref('')
const faqList = ref([])
let ws = null
let pingTimer = null

onMounted(async () => {
  await loadSessions()
  await loadFaqs()
  initWebSocket()
})

onUnmounted(() => {
  if (ws) ws.close()
  if (pingTimer) clearInterval(pingTimer)
})

async function loadSessions() {
  try {
    const res = await imApi.sessionList()
    sessions.value = res.data || []
    if (sessions.value.length > 0 && !activeSession.value) {
      selectSession(sessions.value[0])
    }
  } catch (e) {
    console.error(e)
  }
}

async function loadFaqs() {
  try {
    const res = await faqApi.list({ pageSize: 50, status: 1 })
    faqList.value = (res.data && res.data.list) ? res.data.list : []
  } catch (e) {
    console.error(e)
  }
}

async function selectSession(s) {
  activeSession.value = s
  loading.value = true
  try {
    const res = await imApi.history(s.id, 1, 100)
    messages.value = res.data || []
    s.unreadCountCs = 0
    scrollToBottom()
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function initWebSocket() {
  const token = localStorage.getItem('token')
  if (!token) return

  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  // 智能适配端口：如果当前通过 5173/8080 等前端端口访问，指向 3001；若线上统一端口部署则走同源
  const wsHost = (window.location.port && window.location.port !== '80' && window.location.port !== '443' && window.location.port !== '3001')
    ? `${window.location.hostname}:3001`
    : `${window.location.host}`
  const wsUrl = `${protocol}//${wsHost}/ws/im?token=${token}`

  try {
    ws = new WebSocket(wsUrl)
    ws.onopen = () => {
      pingTimer = setInterval(() => {
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ type: 'ping' }))
        }
      }, 25000)
    }

    ws.onerror = (err) => {
      console.warn('WebSocket 连接未建立，当前使用轮询刷新机制:', err)
    }

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        if (data.type === 'chat' && data.message) {
          const msg = data.message
          if (activeSession.value && msg.sessionId === activeSession.value.id) {
            messages.value.push(msg)
            scrollToBottom()
            // 标记已读
            imApi.markRead(activeSession.value.id)
          }
          // 刷新会话列表
          loadSessions()
        } else if (data.type === 'transfer') {
          ElMessage.info('收到新的用户转人工接入请求！')
          loadSessions()
        }
      } catch (e) {}
    }
  } catch (e) {
    console.warn('WebSocket 初始化异常:', e)
  }
}

function send() {
  const text = inputContent.value.trim()
  if (!text) return
  if (!activeSession.value) {
    ElMessage.warning('请先选择会话')
    return
  }

  const clientMsgId = 'cs_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7)
  const payload = {
    type: 'chat',
    sessionId: activeSession.value.id,
    clientMsgId,
    senderType: 2, // 客服
    receiverId: activeSession.value.userId,
    msgType: 'text',
    content: text,
  }

  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(payload))
  }

  messages.value.push({
    sessionId: activeSession.value.id,
    clientMsgId,
    senderType: 2,
    senderName: '我 (人工客服)',
    content: text,
    createdAt: new Date().toLocaleTimeString(),
  })

  inputContent.value = ''
  scrollToBottom()
}

function quickReply(faq) {
  inputContent.value = faq.answer
}

function scrollToBottom() {
  nextTick(() => {
    const el = document.getElementById('msg-container')
    if (el) el.scrollTop = el.scrollHeight
  })
}
</script>

<template>
  <div class="desk-container">
    <!-- 左侧会话列表 -->
    <div class="session-panel">
      <div class="panel-header">
        <span class="title">会话列表</span>
        <el-button link type="primary" @click="loadSessions">刷新</el-button>
      </div>
      <div class="session-list">
        <div
          v-for="s in sessions"
          :key="s.id"
          class="session-item"
          :class="{ active: activeSession && activeSession.id === s.id }"
          @click="selectSession(s)"
        >
          <div class="avatar">{{ s.userName ? s.userName.charAt(0) : '用' }}</div>
          <div class="info">
            <div class="info-top">
              <span class="user-name">{{ s.userName || '家长用户 #' + s.userId }}</span>
              <span class="time">{{ (s.lastMsgTime || '').slice(11, 16) }}</span>
            </div>
            <div class="info-bottom">
              <span class="msg-preview">{{ s.lastMsgContent || '暂无消息' }}</span>
              <el-badge v-if="s.unreadCountCs > 0" :value="s.unreadCountCs" class="unread-badge" />
            </div>
            <div class="tag-row">
              <el-tag size="small" :type="s.sessionType === 2 ? 'danger' : 'info'">
                {{ s.sessionType === 2 ? '人工服务中' : 'AI接待中' }}
              </el-tag>
              <span class="store-tag">{{ s.storeName || '全平台' }}</span>
            </div>
          </div>
        </div>
        <div v-if="!sessions.length" class="empty-text">暂无咨询会话</div>
      </div>
    </div>

    <!-- 右侧聊天主面板 -->
    <div class="chat-panel" v-if="activeSession">
      <div class="chat-header">
        <div class="user-info">
          <span class="name">{{ activeSession.userName || '用户 #' + activeSession.userId }}</span>
          <el-tag size="small" :type="activeSession.sessionType === 2 ? 'danger' : 'warning'">
            {{ activeSession.sessionType === 2 ? '人工对话' : 'AI 对话（已同步历史记录）' }}
          </el-tag>
          <span class="store-name">🏢 所属门店：{{ activeSession.storeName }}</span>
        </div>
        <div class="quick-faq">
          <el-dropdown trigger="click">
            <el-button type="primary" plain size="small">
              常用快捷回复 <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item v-for="faq in faqList" :key="faq.id" @click="quickReply(faq)">
                  【{{ faq.category }}】{{ faq.question }}
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <!-- 消息记录区域 -->
      <div class="chat-body" id="msg-container" v-loading="loading">
        <div v-for="(m, idx) in messages" :key="idx" class="msg-row" :class="m.senderType === 2 ? 'right' : 'left'">
          <!-- 系统消息 -->
          <div v-if="m.senderType === 4" class="system-msg">
            <span class="sys-badge">{{ m.content }}</span>
          </div>

          <!-- 普通/AI/客服消息 -->
          <template v-else>
            <div class="avatar-box">
              <span v-if="m.senderType === 3" class="bot-ico">🤖</span>
              <span v-else-if="m.senderType === 2" class="cs-ico">👨‍💼</span>
              <span v-else class="user-ico">👤</span>
            </div>
            <div class="msg-content-box">
              <div class="meta">
                <span class="sender-label">
                  {{ m.senderType === 3 ? 'AI 智能助手' : (m.senderType === 2 ? '人工客服' : (m.senderName || '用户')) }}
                </span>
                <span class="msg-time">{{ (m.createdAt || '').slice(11, 19) }}</span>
              </div>
              <div class="bubble" :class="{ 'bubble-cs': m.senderType === 2, 'bubble-ai': m.senderType === 3 }">
                {{ m.content }}
              </div>
            </div>
          </template>
        </div>
      </div>

      <!-- 输入栏 -->
      <div class="chat-footer">
        <el-input
          v-model="inputContent"
          type="textarea"
          :rows="3"
          placeholder="请输入回复内容，按 Ctrl + Enter 或点击发送..."
          @keydown.enter.ctrl="send"
        />
        <div class="footer-actions">
          <span class="tip">Ctrl + Enter 快捷发送</span>
          <el-button type="primary" @click="send">发送回复</el-button>
        </div>
      </div>
    </div>

    <div class="chat-panel empty-panel" v-else>
      <div class="empty-state">请从左侧选择一个会话开始接待</div>
    </div>
  </div>
</template>

<style scoped>
.desk-container {
  display: flex;
  height: calc(100vh - 120px);
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  border: 1px solid var(--border-color);
  overflow: hidden;
}

.session-panel {
  width: 300px;
  min-width: 280px;
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  background: #FAFBFC;
}

.panel-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #FFFFFF;
}
.panel-header .title { font-size: 15px; font-weight: 700; color: var(--text-heading); }

.session-list { flex: 1; overflow-y: auto; }
.session-item {
  display: flex;
  padding: 14px 16px;
  border-bottom: 1px solid var(--border-light);
  cursor: pointer;
  transition: all .2s;
  gap: 12px;
  position: relative;
  background: transparent;
}
.session-item:hover { background: #F3F4F6; }
.session-item.active {
  background: var(--brand-light);
}
.session-item.active::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 3px;
  background: var(--brand-primary);
}

.session-item .avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--brand-primary), #FF9138);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 15px;
  flex-shrink: 0;
  box-shadow: var(--shadow-subtle);
}

.session-item .info { flex: 1; min-width: 0; }
.info-top { display: flex; justify-content: space-between; align-items: center; }
.user-name { font-size: 14px; font-weight: 600; color: var(--text-heading); }
.time { font-size: 12px; color: var(--text-secondary); }
.info-bottom { display: flex; justify-content: space-between; align-items: center; margin-top: 4px; }
.msg-preview { font-size: 12px; color: var(--text-body); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 170px; }
.tag-row { margin-top: 6px; display: flex; gap: 6px; align-items: center; }
.store-tag { font-size: 11px; color: var(--text-secondary); }

.chat-panel { flex: 1; min-width: 0; display: flex; flex-direction: column; background: #FFFFFF; }
.chat-header {
  padding: 14px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--bg-page);
}
.user-info { display: flex; align-items: center; gap: 10px; }
.user-info .name { font-size: 15px; font-weight: 700; color: var(--text-heading); }
.user-info .store-name { font-size: 12px; color: var(--text-secondary); }

.chat-body {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: var(--bg-page);
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.msg-row { display: flex; gap: 10px; max-width: 75%; }
.msg-row.right { align-self: flex-end; flex-direction: row-reverse; }
.msg-row.left { align-self: flex-start; }

.avatar-box {
  width: 36px; height: 36px; border-radius: 50%;
  background: #fff; display: flex; align-items: center; justify-content: center;
  box-shadow: var(--shadow-subtle); font-size: 18px; flex-shrink: 0;
  border: 1px solid var(--border-color);
}

.msg-content-box { display: flex; flex-direction: column; }
.meta { font-size: 12px; color: var(--text-secondary); margin-bottom: 4px; display: flex; gap: 8px; }
.msg-row.right .meta { justify-content: flex-end; }

.bubble {
  padding: 10px 14px;
  background: #fff;
  border-radius: var(--radius-md);
  color: var(--text-heading);
  font-size: 14px;
  line-height: 1.5;
  box-shadow: var(--shadow-subtle);
  border: 1px solid var(--border-color);
  word-break: break-all;
}
.bubble-cs {
  background: linear-gradient(135deg, var(--brand-primary), #FF9138);
  color: #fff;
  border: none;
  box-shadow: 0 2px 8px rgba(255, 122, 24, 0.25);
}
.bubble-ai {
  background: #FFF9F2;
  border: 1px solid #FFE7D1;
  color: #9A3412;
}

.system-msg { width: 100%; text-align: center; margin: 4px 0; }
.sys-badge { background: #E5E7EB; color: var(--text-body); font-size: 12px; padding: 4px 14px; border-radius: var(--radius-pill); }

.chat-footer {
  padding: 14px 20px;
  border-top: 1px solid var(--border-color);
  background: #fff;
}
.footer-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}
.footer-actions .tip { font-size: 12px; color: var(--text-secondary); }

.empty-panel { align-items: center; justify-content: center; background: var(--bg-page); }
.empty-state { color: var(--text-secondary); font-size: 15px; }
.empty-text { text-align: center; color: var(--text-placeholder); margin-top: 40px; }
</style>
