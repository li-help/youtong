<template>
  <view class="ai">
    <view class="status-bar"></view>
    <view class="header">
      <text class="title">智能推荐</text>
      <text class="subtitle">告诉我们宝宝的情况，定制成长方案</text>
    </view>

    <view class="card form-card">
      <view class="block">
        <text class="label">宝宝年龄</text>
        <view class="age-options">
          <view class="age-opt" v-for="a in ages" :key="a.key"
                :class="{ active: form.age === a.key }" @click="form.age = a.key">
            {{ a.label }}（{{ a.key }}岁）
          </view>
        </view>
      </view>

      <view class="block">
        <view class="slider-head">
          <text class="label">身高</text>
          <text class="val">{{ form.height }} cm</text>
        </view>
        <slider :value="form.height" min="40" max="160" block-size="20" activeColor="#FFA000" @change="(e)=>form.height=e.detail.value" />
      </view>

      <view class="block">
        <view class="slider-head">
          <text class="label">体重</text>
          <text class="val">{{ form.weight }} kg</text>
        </view>
        <slider :value="form.weight" min="3" max="60" block-size="20" activeColor="#FFA000" @change="(e)=>form.weight=e.detail.value" />
      </view>

      <view class="block">
        <text class="label">兴趣方向（可多选）</text>
        <view class="interest-options">
          <view class="interest-opt" v-for="it in interests" :key="it"
                :class="{ active: form.interests.includes(it) }" @click="toggleInterest(it)">
            {{ it }}
          </view>
        </view>
      </view>

      <button class="btn-primary submit" @click="onRecommend">查 看 推 荐</button>
    </view>

    <view class="footer-tip">🤖 基于宝宝成长数据，智能匹配课程与活动</view>
  </view>
</template>

<script setup>
import { reactive } from 'vue'

const ages = [
  { key: '0-3', label: '启蒙期' },
  { key: '3-6', label: '幼龄段' },
  { key: '6-9', label: '学龄段' },
  { key: '9+', label: '成长段' }
]
const interests = ['绘本阅读', '益智游戏', '科学启蒙', '艺术创作', '运动健康', '音乐律动']

const form = reactive({
  age: '3-6',
  height: 110,
  weight: 20,
  interests: ['绘本阅读', '益智游戏']
})

function toggleInterest(it) {
  const i = form.interests.indexOf(it)
  if (i >= 0) form.interests.splice(i, 1)
  else form.interests.push(it)
}

function onRecommend() {
  uni.navigateTo({
    url: '/pages/ai/result?age=' + form.age + '&height=' + form.height + '&weight=' + form.weight + '&interests=' + encodeURIComponent(form.interests.join(','))
  })
}
</script>

<style scoped>
.ai { min-height: 100vh; background: linear-gradient(180deg, #FFF3E0 0%, #FFF8E1 50%); padding: 0 24rpx; }
.status-bar { height: 80rpx; }
.header { padding: 30rpx 12rpx 20rpx; }
.title { font-size: 44rpx; font-weight: bold; color: #FF8F00; display: block; }
.subtitle { font-size: 26rpx; color: #B26A00; margin-top: 10rpx; display: block; }
.form-card { margin-top: 10rpx; }
.block { margin-bottom: 36rpx; }
.label { font-size: 30rpx; font-weight: bold; color: #444; display: block; margin-bottom: 18rpx; }
.age-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.age-opt { padding: 14rpx 28rpx; border-radius: 40rpx; background: #FFF3E0; color: #B26A00; font-size: 26rpx; }
.age-opt.active { background: linear-gradient(90deg, #FFC107, #FFA000); color: #fff; }
.slider-head { display: flex; justify-content: space-between; align-items: center; }
.val { color: #FFA000; font-weight: bold; }
.interest-options { display: flex; flex-wrap: wrap; gap: 16rpx; }
.interest-opt { padding: 14rpx 28rpx; border-radius: 40rpx; background: #FFF3E0; color: #B26A00; font-size: 26rpx; }
.interest-opt.active { background: linear-gradient(90deg, #FFC107, #FFA000); color: #fff; }
.submit { margin-top: 10rpx; }
.footer-tip { text-align: center; color: #B26A00; font-size: 24rpx; margin-top: 30rpx; }
</style>
