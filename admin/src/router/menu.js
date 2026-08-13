// 后台菜单配置 —— 对应设计图左侧导航
export const menus = [
  { path: '/system', title: '系统管理', icon: 'Setting', children: [
    { path: '/system/account', title: '账号管理' },
  ]},
  { path: '/ad', title: '广告管理', icon: 'Picture', children: [
    { path: '/ad/position', title: '广告位' },
    { path: '/ad/list', title: '广告列表' },
  ]},
  { path: '/video', title: '视频管理', icon: 'VideoCamera', children: [
    { path: '/video/list', title: '视频列表' },
  ]},
  { path: '/store', title: '店铺管理', icon: 'Shop', children: [
    { path: '/store/list', title: '店铺列表' },
  ]},
  { path: '/course', title: '课程管理', icon: 'Reading', children: [
    { path: '/course/list', title: '课程列表' },
  ]},
  { path: '/activity', title: '活动管理', icon: 'Calendar', children: [
    { path: '/activity/list', title: '活动列表' },
  ]},
  { path: '/article', title: '文章管理', icon: 'Document', children: [
    { path: '/article/list', title: '文章列表' },
  ]},
  { path: '/category', title: '分类管理', icon: 'Menu', children: [
    { path: '/category/list', title: '分类列表' },
  ]},
  { path: '/user', title: '用户管理', icon: 'User', children: [
    { path: '/user/list', title: '用户列表' },
  ]},
  { path: '/order', title: '订单管理', icon: 'List', children: [
    { path: '/order/list', title: '订单列表' },
  ]},
  { path: '/service', title: '客服管理', icon: 'Service', children: [
    { path: '/service/list', title: '客服列表' },
  ]},
]

export default menus
