import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Botstrap',
  description:
    'Cross-platform bootstrap for developers and AI agents: YAML registries, phased install (prerequisites, core, TUI, configure, verify), configs/ templates, and a detailed reference for CLI and environment variables.',
  lang: 'en-US',
  base: '/',
  cleanUrls: true,
  appearance: 'dark',

  themeConfig: {
    siteTitle: 'Botstrap',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Introduction', link: '/INTRODUCTION' },
      { text: 'Getting started', link: '/GETTING_STARTED' },
      { text: 'Architecture', link: '/ARCHITECTURE' },
      {
        text: 'More',
        items: [
          { text: 'Reference', link: '/REFERENCE' },
          { text: 'Configuration', link: '/CONFIGURATION' },
          { text: 'Registry specification', link: '/REGISTRY_SPEC' },
          { text: 'Tool selection', link: '/TOOL_SELECTION' },
          { text: 'Cross-platform', link: '/CROSS_PLATFORM' },
          { text: 'AI agent friendliness', link: '/AI_AGENT_FRIENDLINESS' },
          { text: 'Contributing', link: '/CONTRIBUTING' },
        ],
      },
    ],

    sidebar: [
      {
        text: 'Documentation',
        items: [
          { text: 'Introduction', link: '/INTRODUCTION' },
          { text: 'Getting started', link: '/GETTING_STARTED' },
          { text: 'Architecture', link: '/ARCHITECTURE' },
          { text: 'Reference', link: '/REFERENCE' },
          { text: 'Configuration', link: '/CONFIGURATION' },
          { text: 'Registry specification', link: '/REGISTRY_SPEC' },
          { text: 'Tool selection', link: '/TOOL_SELECTION' },
          { text: 'Cross-platform notes', link: '/CROSS_PLATFORM' },
          { text: 'AI agent friendliness', link: '/AI_AGENT_FRIENDLINESS' },
          { text: 'Contributing', link: '/CONTRIBUTING' },
        ],
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/an-lee/botstrap' },
    ],

    editLink: {
      pattern: 'https://github.com/an-lee/botstrap/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },

    search: {
      provider: 'local',
    },

    footer: {
      message:
        'Botstrap — cross-platform bootstrap for developers and AI coding agents.',
      copyright: `Copyright © ${new Date().getFullYear()} Botstrap contributors`,
    },
  },
})
