<template>
  <view class="app-nav" :class="{ 'app-nav--gradient': gradient }">
    <view class="app-nav__inner">
      <view v-if="back" class="app-nav__back" @click="onBack">‹</view>
      <text class="app-nav__title">{{ title }}</text>
      <view class="app-nav__extra">
        <slot name="right" />
      </view>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  title: { type: String, default: '' },
  back: { type: Boolean, default: false },
  gradient: { type: Boolean, default: false }
})
function onBack() {
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
  } else {
    uni.switchTab({ url: '/pages/tabbar/home/home' })
  }
}
</script>
