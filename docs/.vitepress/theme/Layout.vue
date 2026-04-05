<script setup lang="ts">
import { useRoute } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import DocsSiteVersion from './DocsSiteVersion.vue'
import InstallCommand from './InstallCommand.vue'

const { Layout } = DefaultTheme
const route = useRoute()
</script>

<template>
  <Layout>
    <template #home-hero-actions-after>
      <InstallCommand />
    </template>
    <template #layout-bottom>
      <div v-if="route.path !== '/'" class="docs-site-version-layout">
        <DocsSiteVersion />
      </div>
    </template>
  </Layout>
</template>

<style scoped>
.docs-site-version-layout {
  padding: 0 1.5rem 1.25rem;
  text-align: center;
}
</style>
