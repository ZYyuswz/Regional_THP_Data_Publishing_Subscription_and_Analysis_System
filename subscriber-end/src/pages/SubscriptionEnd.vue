<template>
  <h1>订阅端</h1>
  <el-button size='large' @click="router.push('/home')">主页</el-button>
  <el-button size='large' @click="router.push('/pub')">发布端</el-button>
  <el-alert
    v-if="!isConnected"
    type="warning"
    :closable="false"
    style="margin-bottom: 10px;"
  >
    等待 MQTT 连接中... 请等待连接成功后再订阅
  </el-alert>
  <el-alert
    v-else
    type="success"
    :closable="false"
    style="margin-bottom: 10px;"
  >
    ✓ MQTT 已连接，可以开始订阅了！建议先订阅再发布，确保不丢失数据
  </el-alert>
  <el-button size='large' @click="toggleSubscription('temperature')">
    {{ isSubscribedToTemperature ? '取消订阅温度数据' : '订阅温度数据' }}
  </el-button>
  <el-button size='large' @click="toggleSubscription('humidity')">
    {{ isSubscribedToHumidity ? '取消订阅湿度数据' : '订阅湿度数据' }}
  </el-button>
  <el-button size='large' @click="toggleSubscription('pressure')">
    {{ isSubscribedToPressure ? '取消订阅气压数据' : '订阅气压数据' }}
  </el-button>
  <el-tabs v-model='activeName'>
    <el-tab-pane label='温度数据' name='temperature'>
      <img v-if='temperatureImageSrc' :src='`data:image/png;base64,${temperatureImageSrc}`' alt='temperatureImage'>
      <el-table :data='temperatureData' style='width: 100%'>
        <el-table-column prop='date' label='日期' width='180'/>
        <el-table-column prop='average' label='平均温度' width='180'/>
        <el-table-column label='查看图片'>
          <template #default='scope'>
            <el-button link type='primary' @click='showImage(scope.row.graph)'>
              数据折线图
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-tab-pane>
    <el-tab-pane label='湿度数据' name='humidity'>
      <img v-if='humidityImageSrc' :src='`data:image/png;base64,${humidityImageSrc}`' alt='humidityImage'>
      <el-table :data='humidityData' style='width: 100%'>
        <el-table-column prop='date' label='日期' width='180'/>
        <el-table-column prop='average' label='平均湿度' width='180'/>
        <el-table-column label='查看图片'>
          <template #default='scope'>
            <el-button link type='primary' @click='showImage(scope.row.graph)'>
              数据折线图
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-tab-pane>
    <el-tab-pane label='气压数据' name='pressure'>
      <img v-if='pressureImageSrc' :src='`data:image/png;base64,${pressureImageSrc}`' alt='pressureImage'>
      <el-table :data='pressureData' style='width: 100%'>
        <el-table-column prop='date' label='日期' width='180'/>
        <el-table-column prop='average' label='平均气压' width='180'/>
        <el-table-column label='查看图片'>
          <template #default='scope'>
            <el-button link type='primary' @click='showImage(scope.row.graph)'>
              数据折线图
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-tab-pane>
  </el-tabs>
  <el-dialog v-model='imageDialogVisible' title='数据折线图' width='1200'>
    <img :src='imageSrc' alt='graph' style='width: 100%'/>
  </el-dialog>
</template>

<script setup lang='ts'>
import mqtt from 'mqtt'
import {ref, onMounted, onBeforeUnmount} from 'vue'
import {useRouter} from 'vue-router'
import {ElMessage} from 'element-plus'
import {MQTT_WS_URL, MQTT_USERNAME, MQTT_PASSWORD} from '../config'

const router = useRouter()
const client = ref<mqtt.MqttClient | null>(null)
const isConnected = ref(false)
const temperatureData = ref<any[]>([])
const humidityData = ref<any[]>([])
const pressureData = ref<any[]>([])
const isSubscribedToTemperature = ref(false)
const isSubscribedToHumidity = ref(false)
const isSubscribedToPressure = ref(false)
const imageDialogVisible = ref(false)
const imageSrc = ref('')
const activeName = ref('temperature')
const temperatureImageSrc = ref('')
const humidityImageSrc = ref('')
const pressureImageSrc = ref('')

const connectToMQTT = () => {
  console.log('🔌 正在连接 MQTT...', MQTT_WS_URL)
  client.value = mqtt.connect(MQTT_WS_URL, {
    username: MQTT_USERNAME,
    password: MQTT_PASSWORD,
    clientId: crypto.randomUUID(),
    clean: true,
    reconnectPeriod: 5000, // 5秒后重连
    connectTimeout: 10000 // 10秒连接超时
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('connect', () => {
    console.log('✅ MQTT 连接成功')
    isConnected.value = true
    ElMessage.success('MQTT 代理已连接')
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('message', (topic, message) => {
    console.log('📨 收到消息:', { topic, messageLength: message.length })
    try {
      const messageStr = message.toString()
      console.log('📄 消息内容:', messageStr.substring(0, 200)) // 只打印前200个字符
      const data = JSON.parse(messageStr)
      console.log('✅ 解析成功:', { topic, date: data.date, average: data.average })
      
      if (topic === 'temperature/data') {
        temperatureData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph
        })
        if (data.prediction) {
          temperatureImageSrc.value = data.prediction
        }
        console.log('✅ 温度数据已更新，当前数据条数:', temperatureData.value.length)
      } else if (topic === 'humidity/data') {
        humidityData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph
        })
        if (data.prediction) {
          humidityImageSrc.value = data.prediction
        }
        console.log('✅ 湿度数据已更新，当前数据条数:', humidityData.value.length)
      } else if (topic === 'pressure/data') {
        pressureData.value.push({
          date: data.date,
          average: data.average,
          graph: data.graph
        })
        if (data.prediction) {
          pressureImageSrc.value = data.prediction
        }
        console.log('✅ 气压数据已更新，当前数据条数:', pressureData.value.length)
      } else {
        console.warn('⚠️ 未知主题:', topic)
      }
    } catch (error) {
      console.error('❌ 消息解析失败:', error)
      console.error('原始消息:', message.toString())
      ElMessage.error(`消息解析失败: ${error}`)
    }
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('error', (err) => {
    console.error('❌ MQTT 连接错误:', err)
    ElMessage.error(`MQTT 代理连接错误: ${err}`)
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('close', () => {
    console.warn('⚠️ MQTT 连接已关闭')
    isConnected.value = false
    ElMessage.warning('MQTT 代理连接关闭')
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('offline', () => {
    console.warn('⚠️ MQTT 客户端离线')
    isConnected.value = false
    ElMessage.warning('MQTT 客户端离线')
  })
  // noinspection TypeScriptUnresolvedReference
  client.value.on('reconnect', () => {
    console.log('🔄 MQTT 正在重连...')
  })
}

const toggleSubscription = (topic: string) => {
  if (!client.value) {
    ElMessage.error('MQTT 代理未连接')
    return
  }
  // 检查连接状态
  if (!client.value.connected) {
    console.error('❌ MQTT 客户端未连接，当前状态:', client.value.connected)
    ElMessage.error('MQTT 代理未连接，请等待连接建立')
    return
  }
  console.log('🔔 切换订阅:', topic, '当前连接状态:', client.value.connected)
  
  if (topic === 'temperature') {
    if (isSubscribedToTemperature.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe('temperature/data', (err) => {
        if (err) {
          ElMessage.error('取消订阅温度数据失败: ', err)
        } else {
          ElMessage.warning('已取消订阅温度数据')
          isSubscribedToTemperature.value = false
        }
      })
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe('temperature/data', {qos: 1}, (err, granted) => {
        if (!err) {
          console.log('✅ 订阅成功: temperature/data', granted)
          ElMessage.success('已订阅温度数据')
          isSubscribedToTemperature.value = true
        } else {
          console.error('❌ 订阅失败: temperature/data', err)
          ElMessage.error(`订阅温度数据失败: ${err}`)
        }
      })
    }
  } else if (topic === 'humidity') {
    if (isSubscribedToHumidity.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe('humidity/data', (err) => {
        if (err) {
          ElMessage.error('取消订阅湿度数据失败: ', err)
        } else {
          ElMessage.warning('已取消订阅湿度数据')
          isSubscribedToHumidity.value = false
        }
      })
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe('humidity/data', {qos: 1}, (err, granted) => {
        if (!err) {
          console.log('✅ 订阅成功: humidity/data', granted)
          ElMessage.success('已订阅湿度数据')
          isSubscribedToHumidity.value = true
        } else {
          console.error('❌ 订阅失败: humidity/data', err)
          ElMessage.error(`订阅湿度数据失败: ${err}`)
        }
      })
    }
  } else if (topic === 'pressure') {
    if (isSubscribedToPressure.value) {
      // noinspection TypeScriptUnresolvedReference
      client.value.unsubscribe('pressure/data', (err) => {
        if (err) {
          ElMessage.error('取消订阅气压数据失败: ', err)
        } else {
          ElMessage.warning('已取消订阅气压数据')
          isSubscribedToPressure.value = false
        }
      })
    } else {
      // noinspection TypeScriptUnresolvedReference
      client.value.subscribe('pressure/data', {qos: 1}, (err, granted) => {
        if (!err) {
          console.log('✅ 订阅成功: pressure/data', granted)
          ElMessage.success('已订阅气压数据')
          isSubscribedToPressure.value = true
        } else {
          console.error('❌ 订阅失败: pressure/data', err)
          ElMessage.error(`订阅气压数据失败: ${err}`)
        }
      })
    }
  }
}

onMounted(() => {
  connectToMQTT()
})

onBeforeUnmount(() => {
  if (client.value) {
    // noinspection TypeScriptUnresolvedReference
    client.value.end()
  }
})

const showImage = (base64Image: string) => {
  imageSrc.value = `data:image/png;base64,${base64Image}`
  imageDialogVisible.value = true
}
</script>
