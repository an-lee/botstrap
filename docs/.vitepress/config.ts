import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Botstrap',
  description:
    'Cross-platform bootstrap for developers and AI coding agents: one entry on macOS, Linux, and Windows — YAML registry, optional gum TUI, configs, verification, and an agent-friendly layout.',
  lang: 'en-US',
  base: '/',
  cleanUrls: true,
  appearance: 'dark',

  themeConfig: {
    siteTitle: 'Botstrap',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Architecture', link: '/ARCHITECTURE' },
      { text: 'Registry', link: '/REGISTRY_SPEC' },
      {
        text: 'More',
        items: [
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
          { text: 'Architecture', link: '/ARCHITECTURE' },
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
