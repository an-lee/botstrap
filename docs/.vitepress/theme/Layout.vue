<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import InstallCommand from './InstallCommand.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <Layout>
    <template #home-hero-actions-after>
      <InstallCommand />
    </template>
  </Layout>
</template>
