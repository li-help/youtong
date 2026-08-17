<template>
  <view class="help">
    <view class="app-nav">
      <view class="app-nav__inner">
        <text class="app-nav__back" @click="goBack">‹</text>
        <text class="app-nav__title">使用说明</text>
      </view>
    </view>

    <view class="section">
      <view class="section-title">📱 快速上手</view>
      <view class="step"><text class="num">1</text><text class="txt">注册 / 登录账号，完善宝宝信息</text></view>
      <view class="step"><text class="num">2</text><text class="txt">在「首页」浏览课程、活动、视频</text></view>
      <view class="step"><text class="num">3</text><text class="txt">在「智能」填写宝宝情况，获取推荐</text></view>
      <view class="step"><text class="num">4</text><text class="txt">报名课程，在「我的订单」查看与核销</text></view>
    </view>

    <view class="section">
      <view class="section-title">❓ 常见问题</view>
      <view class="qa"><text class="q">Q：如何报名课程？</text><text class="a">A：进入课程详情页，点击「立即报名」填写信息并提交即可。</text></view>
      <view class="qa"><text class="q">Q：订单如何核销？</text><text class="a">A：在「我的订单」中找到已支付订单，点击「核销」由门店确认。</text></view>
      <view class="qa"><text class="q">Q：推荐不准怎么办？</text><text class="a">A：可在「智能」页重新填写宝宝年龄、身高体重与兴趣偏好。</text></view>
    </view>

    <view class="contact">
      <text class="c-title">📞 联系我们</text>
      <text class="c-text">客服电话：400-000-0000</text>
      <text class="c-text">工作时间：09:00 - 21:00</text>
    </view>
  </view>
</template>

<script setup>
function goBack() { uni.navigateBack() }
</script>

<style scoped>
.help { min-height: 100vh; background: #F5F6FA; }
.section { margin: 24rpx 32rpx; }
.step { display: flex; align-items: center; background: #fff; border-radius: 24rpx; padding: 22rpx; margin-bottom: 16rpx; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.num { width: 44rpx; height: 44rpx; border-radius: 50%; background: linear-gradient(135deg, #FF9F2E, #F6B51E); color: #fff; text-align: center; line-height: 44rpx; font-size: 26rpx; font-weight: bold; margin-right: 20rpx; }
.txt { font-size: 28rpx; color: #444; }
.qa { background: #fff; border-radius: 24rpx; padding: 22rpx; margin-bottom: 16rpx; display: flex; flex-direction: column; box-shadow: 0 4rpx 20rpx rgba(0,0,0,.04); }
.q { font-size: 28rpx; font-weight: bold; color: #E89B00; margin-bottom: 8rpx; }
.a { font-size: 26rpx; color: #888; line-height: 1.6; }
.contact { margin: 24rpx 32rpx; background: linear-gradient(135deg, #FF9F2E, #F6B51E); border-radius: 24rpx; padding: 30rpx; display: flex; flex-direction: column; box-shadow: 0 8rpx 24rpx rgba(246,181,30,0.30); }
.c-title { font-size: 30rpx; font-weight: bold; color: #fff; margin-bottom: 14rpx; }
.c-text { font-size: 26rpx; color: rgba(255, 255, 255, 0.92); margin: 6rpx 0; }
</style>
