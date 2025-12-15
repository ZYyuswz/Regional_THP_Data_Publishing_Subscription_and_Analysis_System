<template>
  <div class="page">
    <div class="page__header">
      <div>
        <p class="eyebrow">发布端</p>
        <h2>一键发布 / 暂停数据流</h2>
        <p class="desc">
          用于触发温度、湿度、气压数据的发布或暂停操作，配合订阅端完成端到端联调。
        </p>
      </div>
      <div class="header__actions">
        <el-button plain @click="router.push('/home')">返回首页</el-button>
        <el-button type="primary" @click="router.push('/sub')"
          >前往订阅端</el-button
        >
      </div>
    </div>

    <el-card shadow="hover" class="card">
      <div class="card__title">选择发布主题</div>
      <p class="card__hint">
        发布动作多次点击效果相同，可安全重试。若长时间无响应，可刷新页面后重试。
      </p>
      <el-space wrap>
        <el-button
          size="large"
          class="action-btn"
          :loading="loadingTopic === 'temperature'"
          @click="fetchDataByTopic('temperature')"
        >
          发布 / 暂停温度数据
        </el-button>
        <el-button
          size="large"
          class="action-btn"
          :loading="loadingTopic === 'humidity'"
          @click="fetchDataByTopic('humidity')"
        >
          发布 / 暂停湿度数据
        </el-button>
        <el-button
          size="large"
          class="action-btn"
          :loading="loadingTopic === 'pressure'"
          @click="fetchDataByTopic('pressure')"
        >
          发布 / 暂停气压数据
        </el-button>
      </el-space>

      <el-alert
        v-if="responseData"
        :title="responseData"
        type="success"
        show-icon
        class="feedback"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";
import { ElMessage } from "element-plus";
import { API_BASE_URL } from "../config";

const router = useRouter();
const responseData = ref<string | null>(null);
const loadingTopic = ref<string | null>(null);

async function fetchDataByTopic(topic: string) {
  loadingTopic.value = topic;
  responseData.value = null;
  try {
    const { data } = await axios.get(`${API_BASE_URL}/pub/${topic}`);
    responseData.value = typeof data === "string" ? data : JSON.stringify(data);
    ElMessage.success("请求已发送，请在订阅端确认数据");
  } catch (error) {
    console.error("发布请求失败:", error);
    responseData.value = "发布失败，请稍后重试";
    ElMessage.error("发布失败，请检查网络或服务状态");
  } finally {
    loadingTopic.value = null;
  }
}
</script>

<style scoped>
.page {
  max-width: 960px;
  margin: 0 auto;
  padding: 40px 16px 72px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.page__header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.eyebrow {
  margin: 0 0 6px;
  color: #4b61ab;
  font-weight: 700;
}

h2 {
  margin: 0;
  font-size: 28px;
  color: #0f172a;
}

.desc {
  margin: 8px 0 0;
  color: #475569;
  line-height: 1.6;
}

.header__actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.card {
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 12px 38px -18px rgba(31, 41, 55, 0.35);
}

.card__title {
  font-weight: 700;
  font-size: 18px;
  margin-bottom: 6px;
}

.card__hint {
  margin: 0 0 12px;
  color: #6b7280;
}

.feedback {
  margin-top: 16px;
}

.action-btn {
  background: #fff;
  border: 1px solid #d1d5db;
  color: #0f172a;
}

.action-btn:hover {
  border-color: #9ca3af;
  background: #f8fafc;
}
</style>
