import { createRouter, createWebHistory } from 'vue-router'
import Layout from '../layout/Layout.vue'

// 由各菜单动态生成路由（除 layout 外均为懒加载占位页面）
const routes = [
  {
    path: '/',
    component: Layout,
    redirect: '/system/account',
    children: [
      { path: '/system/account', name: '账号管理', component: () => import('../views/SystemAccount.vue') },
      { path: '/ad/list', name: '广告列表', component: () => import('../views/AdList.vue') },
      { path: '/video/list', name: '视频列表', component: () => import('../views/VideoList.vue') },
      { path: '/store/list', name: '店铺列表', component: () => import('../views/StoreList.vue') },
      { path: '/course/list', name: '课程列表', component: () => import('../views/CourseList.vue') },
      { path: '/activity/list', name: '活动列表', component: () => import('../views/ActivityList.vue') },
      { path: '/article/list', name: '文章列表', component: () => import('../views/ArticleList.vue') },
      { path: '/category/list', name: '分类列表', component: () => import('../views/CategoryList.vue') },
      { path: '/user/list', name: '用户列表', component: () => import('../views/UserList.vue') },
      { path: '/order/list', name: '订单列表', component: () => import('../views/OrderList.vue') },
      { path: '/service/list', name: '客服列表', component: () => import('../views/ServiceList.vue') },
    ],
  },
  { path: '/login', name: '登录', component: () => import('../views/Login.vue') },
  { path: '/:pathMatch(.*)*', redirect: '/system/account' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

const WHITE_LIST = ['/login']

router.beforeEach((to) => {
  const token = localStorage.getItem('token')
  if (!token && !WHITE_LIST.includes(to.path)) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }
  if (token && to.path === '/login') {
    return { path: '/' }
  }
  return true
})

export default router
