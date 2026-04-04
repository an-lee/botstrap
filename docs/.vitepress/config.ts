import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

const siteOrigin = 'https://botstrap.dev'

export default withMermaid(
  defineConfig({
    title: 'Botstrap',
    description:
      'Bootstrap for developers and AI agents: YAML registries, phased non-interactive installs, macOS, Linux, and Windows.',
    lang: 'en-US',
    base: '/',
    cleanUrls: true,
    appearance: 'dark',

    head: [
      [
        'link',
        {
          rel: 'icon',
          href: '/logo-mark.svg',
          type: 'image/svg+xml',
        },
      ],
    ],

    transformHead: ({ pageData }) => {
      const rel = pageData.relativePath
      const url =
        rel === 'index.md'
          ? `${siteOrigin}/`
          : `${siteOrigin}/${rel.replace(/\.md$/, '')}`
      const ogImage = `${siteOrigin}/logo.svg`
      return [
        ['link', { rel: 'canonical', href: url }],
        ['meta', { property: 'og:url', content: url }],
        ['meta', { property: 'og:site_name', content: 'Botstrap' }],
        ['meta', { property: 'og:type', content: 'website' }],
        ['meta', { property: 'og:image', content: ogImage }],
        ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
        ['meta', { name: 'twitter:image', content: ogImage }],
      ]
    },

    mermaid: {},

    themeConfig: {
      siteTitle: 'Botstrap',
      logo: { src: '/logo-mark.svg', alt: 'Botstrap' },
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
  }),
)
