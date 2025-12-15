<template>
  <div class="home">
    <div class="bg-decor">
      <img src="/background1.png" class="decor decor-1" alt="Background 1" />
      <img src="/background2.png" class="decor decor-2" alt="Background 2" />
      <img src="/background3.png" class="decor decor-3" alt="Background 3" />
      <img src="/background4.png" class="decor decor-4" alt="Background 4" />
      <img src="/background5.png" class="decor decor-5" alt="Background 5" />
    </div>

    <section class="hero">
      <p class="eyebrow">数据驱动 · 实时发布订阅</p>
      <h1>某区域温度 / 湿度 / 气压数据<br />发布订阅及分析处理系统</h1>
      <p class="sub">支持数据发布、订阅、预测可视化，开箱即用的监控看板</p>
      <div class="actions">
        <el-button
          size="large"
          type="primary"
          color="#5f7ad6"
          @click="router.push('/sub')"
        >
          进入订阅端
        </el-button>
        <el-button size="large" plain @click="router.push('/pub')">
          进入发布端
        </el-button>
      </div>
    </section>

    <section class="panels">
      <el-card class="panel" shadow="hover">
        <div class="panel__title">订阅端</div>
        <p class="panel__desc">
          实时接收温度 / 湿度 / 气压数据，展示折线预测图与日均表格
        </p>
        <div class="chips">
          <span class="chip">MQTT</span>
          <span class="chip">可视化</span>
          <span class="chip">订阅管理</span>
        </div>
        <el-button type="primary" link @click="router.push('/sub')"
          >立即前往</el-button
        >
      </el-card>

      <el-card class="panel" shadow="hover">
        <div class="panel__title">发布端</div>
        <p class="panel__desc">
          一键触发温度 / 湿度 / 气压数据的发布或暂停，快速联调
        </p>
        <div class="chips">
          <span class="chip">一键发布</span>
          <span class="chip">状态反馈</span>
          <span class="chip">轻量操作</span>
        </div>
        <el-button type="primary" link @click="router.push('/pub')"
          >立即前往</el-button
        >
      </el-card>
    </section>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();
</script>

<style scoped>
.home {
  position: relative;
  min-height: 100vh;
  padding: 72px 6vw 96px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 48px;
}

.bg-decor {
  position: absolute;
  inset: 0;
  pointer-events: none;
  opacity: 0.2;
}

.decor {
  position: absolute;
  filter: saturate(0.9);
}

.decor-1 {
  left: 4%;
  top: -22%;
  width: 440px;
}
.decor-2 {
  top: 12%;
  left: 34%;
  width: 100px;
}
.decor-3 {
  top: -10%;
  right: -6%;
  width: 220px;
}
.decor-4 {
  bottom: -45%;
  left: -12%;
  width: 640px;
}
.decor-5 {
  top: 14%;
  right: 8%;
  width: 540px;
}

.hero {
  position: relative;
  max-width: 780px;
  z-index: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.eyebrow {
  display: inline-block;
  width: fit-content;
  padding: 6px 12px;
  background: rgba(59, 130, 246, 0.12);
  color: #1d4ed8;
  border-radius: 999px;
  font-weight: 600;
  font-size: 14px;
  margin: 0;
}

.hero h1 {
  margin: 0;
  font-size: clamp(32px, 4vw, 46px);
  line-height: 1.25;
  font-weight: 800;
  color: #0f172a;
}

.sub {
  margin: 0;
  color: #475569;
  font-size: 17px;
  line-height: 1.6;
}

.actions {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  flex-wrap: wrap;
}

.panels {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
}

.panel {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  backdrop-filter: blur(6px);
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 12px 38px -18px rgba(31, 41, 55, 0.35);
}

.panel__title {
  font-weight: 700;
  font-size: 20px;
  margin-bottom: 8px;
}

.panel__desc {
  margin: 0 0 12px;
  color: #4b5563;
  line-height: 1.6;
}

.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 12px;
}

.chip {
  padding: 6px 10px;
  border-radius: 12px;
  background: #eef2ff;
  color: #4b61ab;
  font-size: 13px;
  font-weight: 600;
}

@media (max-width: 640px) {
  .home {
    padding: 48px 18px 72px;
  }

  .hero h1 {
    font-size: 30px;
  }

  .decor {
    display: none;
  }
}
</style>
