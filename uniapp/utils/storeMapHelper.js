/**
 * 店铺地图定位与导航工具库
 */

/**
 * 安全获取用户当前经纬度定位（带失败优雅降级）
 */
export function getSafeUserLocation() {
  return new Promise((resolve) => {
    uni.getLocation({
      type: 'gcj02',
      success: (res) => {
        resolve({
          success: true,
          lat: res.latitude,
          lng: res.longitude,
          errMsg: ''
        })
      },
      fail: (err) => {
        console.warn('获取定位授权失败或超时，自动降级为默认坐标:', err)
        resolve({
          success: false,
          lat: 39.9042,
          lng: 116.4074,
          errMsg: '无法获取当前定位，已切换为默认城市。您可以手动在地图上查看或选择门店。'
        })
      }
    })
  })
}

/**
 * 计算两个经纬度之间的直线距离（公里或米友好显示）
 */
export function calculateStoreDistance(userLat, userLng, storeLat, storeLng) {
  if (!userLat || !storeLat || !userLng || !storeLng) return ''
  const uLat = Number(userLat)
  const uLng = Number(userLng)
  const sLat = Number(storeLat)
  const sLng = Number(storeLng)
  if (isNaN(uLat) || isNaN(sLat)) return ''

  const R = 6371 // 地球半径 (km)
  const rad = (d) => (d * Math.PI) / 180
  const dLat = rad(sLat - uLat)
  const dLng = rad(sLng - uLng)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(rad(uLat)) * Math.cos(rad(sLat)) * Math.sin(dLng / 2) * Math.sin(dLng / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  const dist = R * c

  if (dist < 1) {
    return `约 ${Math.round(dist * 1000)} 米`
  }
  return `约 ${dist.toFixed(1)} 公里`
}

/**
 * 跨端一键唤起外部地图导航
 */
export function openStoreNavigation(store) {
  if (!store) return
  const lat = Number(store.lat)
  const lng = Number(store.lng)
  if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
    uni.showToast({ title: '该店铺暂无坐标数据', icon: 'none' })
    return
  }

  // #ifndef H5
  // 小程序与 App 端：调用系统原生地图
  uni.openLocation({
    latitude: lat,
    longitude: lng,
    name: store.name || '优童门店',
    address: store.address || '',
    scale: 16,
    fail: () => {
      uni.showToast({ title: '无法唤起地图导航', icon: 'none' })
    }
  })
  // #endif

  // #ifdef H5
  // H5 / 网页端：跳转腾讯地图网页路径规划
  const name = encodeURIComponent(store.name || '优童门店')
  const url = `https://apis.map.qq.com/tools/routeplan/eword=${name}&epointx=${lat}&epointy=${lng}?referer=youtong&key=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77`
  window.open(url, '_blank')
  // #endif
}
