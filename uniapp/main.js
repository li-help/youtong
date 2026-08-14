import { createApp } from 'vue'
import App from './App.vue'

export function createApp() {
  const app = createApp(App)
  return { app }
}
