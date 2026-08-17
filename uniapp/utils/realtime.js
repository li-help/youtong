/**
 * 通用实时同步 hook：后台对某一频道数据增删改后，前端自动刷新。
 *
 * 双通道：
 *  - H5 / App 环境优先用 SSE（/api/sync/stream?channel=xxx）秒级推送；
 *  - 所有端（含小程序）兜底每 POLL_INTERVAL 秒轮询版本号（/api/sync/version?channel=xxx）。
 *
 * 用法：
 *   const { start, stop } = useRealtime('course', () => loadList())
 *   onShow(() => start())
 *   onHide(() => stop())
 */
import { syncApi } from '../api/index.js'

const POLL_INTERVAL = 5000

export function useRealtime(channel, onRefresh) {
  let pollTimer = null
  let sseTask = null
  let lastVersion = 0

  async function pollVersion() {
    try {
      const v = await syncApi.version(channel)
      if (typeof v === 'number' && v !== lastVersion) {
        lastVersion = v
        if (typeof onRefresh === 'function') onRefresh()
      }
    } catch (e) { /* 忽略网络抖动 */ }
  }

  function startPolling() {
    stopPolling()
    pollTimer = setInterval(pollVersion, POLL_INTERVAL)
  }

  function stopPolling() {
    if (pollTimer) {
      clearInterval(pollTimer)
      pollTimer = null
    }
  }

  function startSSE() {
    // #ifdef H5
    if (typeof EventSource === 'undefined') return
    try {
      sseTask = new EventSource(syncApi.streamUrl(channel))
      sseTask.addEventListener('version', (ev) => {
        const v = Number(ev.data)
        if (!isNaN(v) && v !== lastVersion) {
          lastVersion = v
          if (typeof onRefresh === 'function') onRefresh()
        }
      })
    } catch (e) { sseTask = null }
    // #endif
  }

  function stopSSE() {
    // #ifdef H5
    if (sseTask) {
      try { sseTask.close() } catch (e) {}
      sseTask = null
    }
    // #endif
  }

  function start() {
    // 先取一次基准版本号
    pollVersion()
    startSSE()
    startPolling()
  }

  function stop() {
    stopPolling()
    stopSSE()
  }

  return { start, stop }
}
