import { get, post, del } from './request.js'

export const authApi = {
  login: (username, password) => post('/auth/login', { username, password }),
  logout: () => post('/auth/logout'),
  info: () => post('/auth/info')
}

export const userApi = {
  list: (p) => get('/user', p),
  save: (d) => post('/user', d),
  remove: (id) => del(`/user/${id}`)
}

export const videoApi = {
  list: (p) => get('/video', p),
  detail: (id) => get(`/video/${id}`)
}

export const courseApi = {
  list: (p) => get('/course', p),
  detail: (id) => get(`/course/${id}`),
  save: (d) => post('/course', d),
  remove: (id) => del(`/course/${id}`)
}

export const activityApi = {
  list: (p) => get('/activity', p),
  detail: (id) => get(`/activity/${id}`),
  save: (d) => post('/activity', d),
  remove: (id) => del(`/activity/${id}`)
}

export const storeApi = {
  list: (p) => get('/store', p),
  detail: (id) => get(`/store/${id}`)
}

export const categoryApi = {
  list: (p) => get('/category', p)
}

export const adApi = {
  list: (p) => get('/ad', p),
  byPosition: (code) => get(`/banner/${code}`)
}

export const articleApi = {
  list: (p) => get('/article', p)
}

export const orderApi = {
  list: (p) => get('/order', p),
  create: (d) => post('/order/create', d),
  verify: (id) => post(`/order/${id}/verify`)
}
