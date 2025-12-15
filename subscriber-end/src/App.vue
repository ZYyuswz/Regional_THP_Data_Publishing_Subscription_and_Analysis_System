<template>
  <div class="app-shell">
    <router-view />
  </div>
</template>

<style>
:root {
  color: #1f2d3d;
  font-family: "Inter", "Segoe UI", system-ui, -apple-system, sans-serif;
  background-color: #f7f9fb;
  /* 温柔的低饱和蓝做主题 */
  --el-color-primary: #5f7ad6;
  --el-color-primary-light-3: #8799e0;
  --el-color-primary-light-5: #b3c1ec;
  --el-color-primary-light-7: #d9e0f6;
  --el-color-primary-light-9: #f2f4fb;
  --el-color-primary-dark-2: #4b61ab;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: radial-gradient(
      circle at 10% 20%,
      rgba(67, 136, 255, 0.08),
      transparent 25%
    ),
    radial-gradient(circle at 90% 10%, rgba(255, 129, 67, 0.1), transparent 25%),
    #f7f9fb;
}

.app-shell {
  min-height: 100vh;
}
</style>
