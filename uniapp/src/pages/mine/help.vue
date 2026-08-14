<template>
  <view class="help">
    <view class="status-bar"></view>
    <view class="header">
      <text class="back" @click="goBack">‹</text>
      <text class="title">使用说明</text>
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
.help { min-height: 100vh; background: #FFF8E1; }
.status-bar { height: 80rpx; }
.header { display: flex; align-items: center; padding: 16rpx 24rpx 24rpx; }
.back { font-size: 56rpx; color: #FF8F00; width: 60rpx; }
.title { font-size: 38rpx; font-weight: bold; color: #FF8F00; margin-left: 16rpx; }
.section { margin: 24rpx; }
.step { display: flex; align-items: center; background: #fff; border-radius: 14rpx; padding: 20rpx; margin-bottom: 14rpx; }
.num { width: 44rpx; height: 44rpx; border-radius: 50%; background: #FFA000; color: #fff; text-align: center; line-height: 44rpx; font-size: 26rpx; margin-right: 20rpx; }
.txt { font-size: 28rpx; color: #444; }
.qa { background: #fff; border-radius: 14rpx; padding: 20rpx; margin-bottom: 14rpx; display: flex; flex-direction: column; }
.q { font-size: 28rpx; font-weight: bold; color: #FF8F00; margin-bottom: 8rpx; }
.a { font-size: 26rpx; color: #666; line-height: 1.6; }
.contact { margin: 24rpx; background: linear-gradient(135deg,#FFE082,#FFCC80); border-radius: 20rpx; padding: 30rpx; display: flex; flex-direction: column; }
.c-title { font-size: 30rpx; font-weight: bold; color: #6D4C00; margin-bottom: 14rpx; }
.c-text { font-size: 26rpx; color: #6D4C00; margin: 6rpx 0; }
</style>
