<template>
  <div class="page">
    <div class="page__header">
      <div>
        <p class="eyebrow">订阅端</p>
        <h2>实时订阅与可视化</h2>
        <p class="desc">
          订阅温度 / 湿度 / 气压数据，查看表格与折线图预测。建议先订阅再发布。
        </p>
      </div>
      <div class="header__actions">
        <el-button class="outline-btn" plain @click="router.push('/home')"
          >返回首页</el-button
        >
        <el-button class="outline-btn" plain @click="router.push('/pub')"
          >前往发布端</el-button
        >
      </div>
    </div>

    <el-card shadow="hover" class="card">
      <el-alert
        v-if="!isConnected"
        type="warning"
        :closable="false"
        class="alert"
      >
        等待 MQTT 连接中... 请等待连接成功后再订阅
      </el-alert>
      <el-alert v-else type="success" :closable="false" class="alert">
        ✓ MQTT 已连接，可以开始订阅了！建议先订阅再发布，确保不丢失数据
      </el-alert>

      <div class="action-row">
        <el-button
          size="large"
          class="outline-btn"
          plain
          @click="toggleSubscription('temperature')"
        >
          {{ isSubscribedToTemperature ? "取消订阅温度数据" : "订阅温度数据" }}
        </el-button>
        <el-button
          size="large"
          class="outline-btn"
          plain
          @click="toggleSubscription('humidity')"
        >
          {{ isSubscribedToHumidity ? "取消订阅湿度数据" : "订阅湿度数据" }}
        </el-button>
        <el-button
          size="large"
          class="outline-btn"
          plain
          @click="toggleSubscription('pressure')"
        >
          {{ isSubscribedToPressure ? "取消订阅气压数据" : "订阅气压数据" }}
        </el-button>
      </div>

      <el-tabs v-model="activeName" class="tabs">
        <el-tab-pane label="温度数据" name="temperature">
          <div class="chart-wrap" v-if="temperatureImageSrc">
            <img
              :src="`data:image/png;base64,${temperatureImageSrc}`"
              alt="temperatureImage"
            />
          </div>
          <el-table :data="temperatureData" style="width: 100%">
            <el-table-column prop="date" label="日期" width="180" />
            <el-table-column prop="average" label="平均温度" width="180" />
            <el-table-column label="查看图片">
              <template #default="scope">
                <el-button
                  link
                  type="primary"
                  @click="showImage(scope.row.graph)"
                >
                  数据折线图
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="湿度数据" name="humidity">
          <div class="chart-wrap" v-if="humidityImageSrc">
            <img
              :src="`data:image/png;base64,${humidityImageSrc}`"
              alt="humidityImage"
            />
          </div>
          <el-table :data="humidityData" style="width: 100%">
            <el-table-column prop="date" label="日期" width="180" />
            <el-table-column prop="average" label="平均湿度" width="180" />
            <el-table-column label="查看图片">
              <template #default="scope">
                <el-button
                  link
                  type="primary"
                  @click="showImage(scope.row.graph)"
                >
                  数据折线图
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="气压数据" name="pressure">
          <div class="chart-wrap" v-if="pressureImageSrc">
            <img
              :src="`data:image/png;base64,${pressureImageSrc}`"
              alt="pressureImage"
            />
          </div>
          <el-table :data="pressureData" style="width: 100%">
            <el-table-column prop="date" label="日期" width="180" />
            <el-table-column prop="average" label="平均气压" width="180" />
            <el-table-column label="查看图片">
              <template #default="scope">
                <el-button
                  link
                  type="primary"
                  @click="showImage(scope.row.graph)"
                >
                  数据折线图
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <el-dialog v-model="imageDialogVisible" title="数据折线图" width="1200">
      <img :src="imageSrc" alt="graph" style="width: 100%" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import mqtt from "mqtt";
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { MQTT_WS_URL, MQTT_USERNAME, MQTT_PASSWORD } from "../config";

const router = useRouter();
const client = ref<mqtt.MqttClient | null>(null);
const isConnected = ref(false);
const temperatureData = ref<any[]>([]);
const humidityData = ref<any[]>([]);
const pressureData = ref<any[]>([]);
const isSubscribedToTemperature = ref(false);
const isSubscribedToHumidity = ref(false);
const isSubscribedToPressure = ref(false);
const imageDialogVisible = ref(false);
const imageSrc = ref("");
const activeName = ref("temperature");
const temperatureImageSrc = ref("");
const humidityImageSrc = ref("");
const pressureImageSrc = ref("");

const connectToMQTT = () => {
  console.log("🔌 正在连接 MQTT...", MQTT_WS_URL);
  client.value = mqtt.connect(MQTT_WS_URL, {
    username: MQTT_USERNAME,
    password: MQTT_PASSWORD,
    clientId: crypto.randomUUID(),
    clean: true,
    reconnectPeriod: 5000,
    connectTimeout: 10000,
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("connect", () => {
    console.log("✅ MQTT 连接成功");
    isConnected.value = true;
    ElMessage.success("MQTT 代理已连接");
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("message", (topic, message) => {
    console.log("📨 收到消息:", { topic, messageLength: message.length });
    try {
      const messageStr = message.toString();
      console.log("📄 消息内容:", messageStr.substring(0, 200));
      const data = JSON.parse(messageStr);
      console.log("✅ 解析成功:", {
        topic,
        date: data.date,
        average: data.average,
      });

      if (topic === "temperature/data") {
        temperatureData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph,
        });
        if (data.prediction) {
          temperatureImageSrc.value = data.prediction;
        }
        console.log(
          "✅ 温度数据已更新，当前数据条数:",
          temperatureData.value.length
        );
      } else if (topic === "humidity/data") {
        humidityData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph,
        });
        if (data.prediction) {
          humidityImageSrc.value = data.prediction;
        }
        console.log(
          "✅ 湿度数据已更新，当前数据条数:",
          humidityData.value.length
        );
      } else if (topic === "pressure/data") {
        pressureData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph,
        });
        if (data.prediction) {
          pressureImageSrc.value = data.prediction;
        }
        console.log(
          "✅ 气压数据已更新，当前数据条数:",
          pressureData.value.length
        );
      } else {
        console.warn("⚠️ 未知主题:", topic);
      }
    } catch (error) {
      console.error("❌ 消息解析失败:", error);
      console.error("原始消息:", message.toString());
      ElMessage.error(`消息解析失败: ${error}`);
    }
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("error", (err) => {
    console.error("❌ MQTT 连接错误:", err);
    ElMessage.error(`MQTT 代理连接错误: ${err}`);
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("close", () => {
    console.warn("⚠️ MQTT 连接已关闭");
    isConnected.value = false;
    ElMessage.warning("MQTT 代理连接关闭");
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("offline", () => {
    console.warn("⚠️ MQTT 客户端离线");
    isConnected.value = false;
    ElMessage.warning("MQTT 客户端离线");
  });
  // noinspection TypeScriptUnresolvedReference
  client.value.on("reconnect", () => {
    console.log("🔄 MQTT 正在重连...");
  });
};

const toggleSubscription = (topic: string) => {
  if (!client.value) {
    ElMessage.error("MQTT 代理未连接");
    return;
  }
  if (!client.value.connected) {
    console.error("❌ MQTT 客户端未连接，当前状态:", client.value.connected);
    ElMessage.error("MQTT 代理未连接，请等待连接建立");
    return;
  }
  console.log("🔔 切换订阅:", topic, "当前连接状态:", client.value.connected);

  if (topic === "temperature") {
    if (isSubscribedToTemperature.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe("temperature/data", (err) => {
        if (err) {
          ElMessage.error("取消订阅温度数据失败: ", err);
        } else {
          ElMessage.warning("已取消订阅温度数据");
          isSubscribedToTemperature.value = false;
        }
      });
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe("temperature/data", { qos: 1 }, (err, granted) => {
        if (!err) {
          console.log("✅ 订阅成功: temperature/data", granted);
          ElMessage.success("已订阅温度数据");
          isSubscribedToTemperature.value = true;
        } else {
          console.error("❌ 订阅失败: temperature/data", err);
          ElMessage.error(`订阅温度数据失败: ${err}`);
        }
      });
    }
  } else if (topic === "humidity") {
    if (isSubscribedToHumidity.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe("humidity/data", (err) => {
        if (err) {
          ElMessage.error("取消订阅湿度数据失败: ", err);
        } else {
          ElMessage.warning("已取消订阅湿度数据");
          isSubscribedToHumidity.value = false;
        }
      });
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe("humidity/data", { qos: 1 }, (err, granted) => {
        if (!err) {
          console.log("✅ 订阅成功: humidity/data", granted);
          ElMessage.success("已订阅湿度数据");
          isSubscribedToHumidity.value = true;
        } else {
          console.error("❌ 订阅失败: humidity/data", err);
          ElMessage.error(`订阅湿度数据失败: ${err}`);
        }
      });
    }
  } else if (topic === "pressure") {
    if (isSubscribedToPressure.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe("pressure/data", (err) => {
        if (err) {
          ElMessage.error("取消订阅气压数据失败: ", err);
        } else {
          ElMessage.warning("已取消订阅气压数据");
          isSubscribedToPressure.value = false;
        }
      });
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe("pressure/data", { qos: 1 }, (err, granted) => {
        if (!err) {
          console.log("✅ 订阅成功: pressure/data", granted);
          ElMessage.success("已订阅气压数据");
          isSubscribedToPressure.value = true;
        } else {
          console.error("❌ 订阅失败: pressure/data", err);
          ElMessage.error(`订阅气压数据失败: ${err}`);
        }
      });
    }
  }
};

onMounted(() => {
  connectToMQTT();
});

onBeforeUnmount(() => {
  if (client.value) {
    // noinspection TypeScriptUnresolvedReference
    client.value.end();
  }
});

const showImage = (base64Image: string) => {
  imageSrc.value = `data:image/png;base64,${base64Image}`;
  imageDialogVisible.value = true;
};
</script>

<style scoped>
.page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 40px 16px 72px;
  display: flex;
  flex-direction: column;
  gap: 18px;
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

.outline-btn {
  background: #fff;
  border: 1px solid #d1d5db;
  color: #0f172a;
}

.outline-btn:hover {
  border-color: #9ca3af;
  background: #f8fafc;
}

.card {
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 16px 40px -22px rgba(31, 41, 55, 0.4);
}

.alert {
  margin-bottom: 12px;
}

.action-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin: 6px 0 18px;
}

.tabs {
  background: #fff;
  border-radius: 10px;
}

.chart-wrap {
  margin-bottom: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  overflow: hidden;
  background: #fff;
}

.chart-wrap img {
  display: block;
  width: 100%;
}
</style>
