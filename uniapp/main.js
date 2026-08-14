import { createApp as createVueApp } from 'vue'
import App from './App.vue'

export function createApp() {
  const app = createVueApp(App)
  return { app }
}
