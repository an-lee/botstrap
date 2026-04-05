import { execSync } from 'node:child_process'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

const siteOrigin = 'https://botstrap.dev'

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '../..')

function resolveDocsCommit(): { short: string; full: string } {
  const fromEnv =
    process.env.CF_PAGES_COMMIT_SHA ||
    process.env.GITHUB_SHA ||
    process.env.VERCEL_GIT_COMMIT_SHA
  if (fromEnv) {
    const full = fromEnv.trim()
    return { full, short: full.slice(0, 7) }
  }
  try {
    const full = execSync('git rev-parse HEAD', {
      cwd: repoRoot,
      encoding: 'utf8',
    }).trim()
    return { full, short: full.slice(0, 7) }
  } catch {
    return { full: '', short: 'local' }
  }
}

const docsCommit = resolveDocsCommit()

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

    vite: {
      define: {
        __DOCS_COMMIT_SHORT__: JSON.stringify(docsCommit.short),
        __DOCS_COMMIT_FULL__: JSON.stringify(docsCommit.full),
      },
    },

    themeConfig: {
      siteTitle: 'Botstrap',
      logo: { src: '/logo-mark.svg', alt: 'Botstrap' },
      nav: [
        { text: 'Home', link: '/' },
        {
          text: 'Guides',
          items: [
            { text: 'Introduction', link: '/INTRODUCTION' },
            { text: 'Getting started', link: '/GETTING_STARTED' },
            { text: 'After install', link: '/AFTER_INSTALL' },
            { text: 'Defaults & customization', link: '/DEFAULTS_AND_CUSTOMIZATION' },
          ],
        },
        {
          text: 'Reference',
          items: [
            { text: 'Architecture', link: '/ARCHITECTURE' },
            { text: 'Reference', link: '/REFERENCE' },
            { text: 'Configuration file map', link: '/CONFIGURATION' },
            { text: 'Registry specification', link: '/REGISTRY_SPEC' },
            { text: 'Tool selection', link: '/TOOL_SELECTION' },
            { text: 'Cross-platform notes', link: '/CROSS_PLATFORM' },
            { text: 'AI agent friendliness', link: '/AI_AGENT_FRIENDLINESS' },
          ],
        },
        { text: 'Contributing', link: '/CONTRIBUTING' },
      ],

      sidebar: [
        {
          text: 'Guides',
          items: [
            { text: 'Introduction', link: '/INTRODUCTION' },
            { text: 'Getting started', link: '/GETTING_STARTED' },
            { text: 'After install', link: '/AFTER_INSTALL' },
            { text: 'Defaults & customization', link: '/DEFAULTS_AND_CUSTOMIZATION' },
          ],
        },
        {
          text: 'Reference',
          items: [
            { text: 'Architecture', link: '/ARCHITECTURE' },
            { text: 'Reference', link: '/REFERENCE' },
            { text: 'Configuration file map', link: '/CONFIGURATION' },
            { text: 'Registry specification', link: '/REGISTRY_SPEC' },
            { text: 'Tool selection', link: '/TOOL_SELECTION' },
            { text: 'Cross-platform notes', link: '/CROSS_PLATFORM' },
            { text: 'AI agent friendliness', link: '/AI_AGENT_FRIENDLINESS' },
          ],
        },
        {
          text: 'Project',
          items: [{ text: 'Contributing', link: '/CONTRIBUTING' }],
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
