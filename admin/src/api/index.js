// ============================================================
// 接口聚合层（真实后端）
// 所有方法走 src/api/request 的 axios 实例，对齐 Java 后端 REST 路径
// ============================================================
import request from './request'

export const sysAccountApi = {
  list: (p) => request.get('/sys/account', { params: p }),
  save: (d) => request.post('/sys/account', d),
  remove: (id) => request.delete(`/sys/account/${id}`),
}

export const authApi = {
  login: (username, password) => request.post('/auth/login', { username, password }),
  logout: () => request.post('/auth/logout'),
  info: () => request.post('/auth/info'),
}

export const userApi = {
  list: (p) => request.get('/user', { params: p }),
  save: (d) => request.post('/user', d),
  remove: (id) => request.delete(`/user/${id}`),
}

export const orderApi = {
  list: (p) => request.get('/order', { params: p }),
  save: (d) => request.post('/order', d),
  remove: (id) => request.delete(`/order/${id}`),
  verify: (id) => request.post(`/order/${id}/verify`),
}

export const storeApi = {
  list: (p) => request.get('/store', { params: p }),
  save: (d) => request.post('/store', d),
  remove: (id) => request.delete(`/store/${id}`),
}

export const categoryApi = {
  list: (p) => request.get('/category', { params: p }),
  save: (d) => request.post('/category', d),
  remove: (id) => request.delete(`/category/${id}`),
}

export const adPositionApi = {
  list: (p) => request.get('/ad/position', { params: p }),
  save: (d) => request.post('/ad/position', d),
  remove: (id) => request.delete(`/ad/position/${id}`),
}

export const adApi = {
  list: (p) => request.get('/ad', { params: p }),
  save: (d) => request.post('/ad', d),
  remove: (id) => request.delete(`/ad/${id}`),
}

export const videoApi = {
  list: (p) => request.get('/video', { params: p }),
  save: (d) => request.post('/video', d),
  remove: (id) => request.delete(`/video/${id}`),
}

export const courseApi = {
  list: (p) => request.get('/course', { params: p }),
  save: (d) => request.post('/course', d),
  remove: (id) => request.delete(`/course/${id}`),
}

export const activityApi = {
  list: (p) => request.get('/activity', { params: p }),
  save: (d) => request.post('/activity', d),
  remove: (id) => request.delete(`/activity/${id}`),
}

export const articleApi = {
  list: (p) => request.get('/article', { params: p }),
  save: (d) => request.post('/article', d),
  remove: (id) => request.delete(`/article/${id}`),
}

export const serviceApi = {
  list: (p) => request.get('/service', { params: p }),
  save: (d) => request.post('/service', d),
  remove: (id) => request.delete(`/service/${id}`),
}
