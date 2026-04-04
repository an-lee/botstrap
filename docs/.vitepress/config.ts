import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Botstrap',
  description:
    'Cross-platform bootstrap: one entry point on macOS, Linux, and Windows to install a core developer toolchain from a YAML registry, optional gum TUI tools, configs, and verification.',
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
      message: 'Botstrap — cross-platform developer bootstrap.',
      copyright: `Copyright © ${new Date().getFullYear()} Botstrap contributors`,
    },
  },
})
