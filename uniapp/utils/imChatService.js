import { WS_URL } from '../config.js'

class ImChatService {
  constructor() {
    this.socketTask = null
    this.isConnected = false
    this.isConnecting = false
    this.listeners = new Set()
    this.msgQueue = new Map() // clientMsgId -> msgObj
    this.pingTimer = null
    this.reconnectTimer = null
  }

  /**
   * 初始化 WebSocket 连接
   */
  connect() {
    const token = uni.getStorageSync('token')
    if (!token) return
    if (this.isConnected || this.isConnecting) return

    this.isConnecting = true
    const wsUrl = `${WS_URL}/ws/im?token=${token}`

    this.socketTask = uni.connectSocket({
      url: wsUrl,
      success: () => {
        this.isConnecting = false
      },
      fail: () => {
        this.isConnecting = false
        this.reconnect()
      }
    })

    if (!this.socketTask) return

    this.socketTask.onOpen(() => {
      this.isConnected = true
      this.isConnecting = false
      this.startHeartbeat()
    })

    this.socketTask.onMessage((res) => {
      try {
        const data = JSON.parse(res.data)
        // 1. 收到 ACK 确认
        if (data.type === 'ACK' && data.clientMsgId) {
          const msg = this.msgQueue.get(data.clientMsgId)
          if (msg) {
            msg.status = 'success'
            msg.id = data.msgId
            msg.createdAt = data.createdAt || msg.createdAt
            this.msgQueue.delete(data.clientMsgId)
            this.notifyListeners({ type: 'ACK', msg })
          }
        } else {
          // 2. 收到普通推送或转接通知
          this.notifyListeners(data)
        }
      } catch (e) {
        console.error('WebSocket 消息解析失败:', e)
      }
    })

    this.socketTask.onError(() => {
      this.isConnected = false
      this.isConnecting = false
      this.reconnect()
    })

    this.socketTask.onClose(() => {
      this.isConnected = false
      this.isConnecting = false
      this.stopHeartbeat()
      this.reconnect()
    })
  }

  /**
   * 注册消息监听器
   */
  onMessage(callback) {
    this.listeners.add(callback)
    return () => this.listeners.delete(callback)
  }

  notifyListeners(data) {
    this.listeners.forEach((fn) => {
      try { fn(data) } catch (e) { console.error(e) }
    })
  }

  /**
   * 发送消息（带重试与发送状态管理）
   */
  sendMessage(msgObj, onStateChange) {
    if (!msgObj.clientMsgId) {
      msgObj.clientMsgId = 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7)
    }
    msgObj.status = 'sending'
    this.msgQueue.set(msgObj.clientMsgId, msgObj)
    onStateChange && onStateChange(msgObj)

    // 6 秒超时防挂起
    setTimeout(() => {
      if (this.msgQueue.has(msgObj.clientMsgId)) {
        msgObj.status = 'fail'
        this.msgQueue.delete(msgObj.clientMsgId)
        onStateChange && onStateChange(msgObj)
      }
    }, 6000)

    if (this.socketTask && this.isConnected) {
      this.socketTask.send({
        data: JSON.stringify(msgObj),
        fail: () => {
          msgObj.status = 'fail'
          this.msgQueue.delete(msgObj.clientMsgId)
          onStateChange && onStateChange(msgObj)
        }
      })
    } else {
      msgObj.status = 'fail'
      this.msgQueue.delete(msgObj.clientMsgId)
      onStateChange && onStateChange(msgObj)
      this.connect()
    }
  }

  /**
   * 失败重发
   */
  retry(msgObj, onStateChange) {
    this.sendMessage(msgObj, onStateChange)
  }

  startHeartbeat() {
    this.stopHeartbeat()
    this.pingTimer = setInterval(() => {
      if (this.socketTask && this.isConnected) {
        this.socketTask.send({ data: JSON.stringify({ type: 'ping' }) })
      }
    }, 25000)
  }

  stopHeartbeat() {
    if (this.pingTimer) {
      clearInterval(this.pingTimer)
      this.pingTimer = null
    }
  }

  reconnect() {
    if (this.reconnectTimer) return
    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = null
      this.connect()
    }, 4000)
  }

  close() {
    this.stopHeartbeat()
    if (this.socketTask) {
      this.socketTask.close({})
      this.socketTask = null
    }
    this.isConnected = false
    this.isConnecting = false
  }
}

export const imChat = new ImChatService()
export default imChat
