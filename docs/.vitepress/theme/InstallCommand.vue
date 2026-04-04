<script setup lang="ts">
import { computed, ref } from 'vue'

type Platform = 'unix' | 'windows'

const platform = ref<Platform>('unix')
const copied = ref(false)
let copyTimer: ReturnType<typeof setTimeout> | undefined

const commands: Record<Platform, string> = {
  unix: 'curl -fsSL https://botstrap.org/install | bash',
  windows: 'irm https://botstrap.org/install.ps1 | iex',
}

const currentCommand = computed(() => commands[platform.value])

async function copyCommand() {
  try {
    await navigator.clipboard.writeText(currentCommand.value)
    copied.value = true
    if (copyTimer !== undefined) {
      clearTimeout(copyTimer)
    }
    copyTimer = setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch {
    // Clipboard may be unavailable; ignore.
  }
}
</script>

<template>
  <div class="install-command">
    <p class="install-command__label">Install</p>
    <div
      class="install-command__tabs"
      role="tablist"
      aria-label="Choose install platform"
    >
      <button
        type="button"
        class="install-command__tab"
        role="tab"
        :aria-selected="platform === 'unix'"
        @click="platform = 'unix'"
      >
        macOS / Linux
      </button>
      <button
        type="button"
        class="install-command__tab"
        role="tab"
        :aria-selected="platform === 'windows'"
        @click="platform = 'windows'"
      >
        Windows
      </button>
    </div>
    <div class="install-command__panel">
      <pre class="install-command__pre"><code>{{ currentCommand }}</code></pre>
      <button
        type="button"
        class="install-command__copy"
        :aria-label="copied ? 'Copied' : 'Copy command'"
        @click="copyCommand"
      >
        {{ copied ? 'Copied' : 'Copy' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.install-command {
  margin-top: 1.5rem;
  width: 100%;
  max-width: 52rem;
}

.install-command__label {
  margin: 0 0 0.75rem;
  font-family: var(--bt-font-mono);
  font-size: 0.875rem;
  color: var(--bt-terminal-white-muted);
}

.install-command__tabs {
  display: flex;
  gap: 0;
  margin-bottom: 0;
  border-radius: 8px 8px 0 0;
  overflow: hidden;
  border: 1px solid var(--bt-terminal-border);
  border-bottom: none;
}

.install-command__tab {
  flex: 1;
  padding: 0.5rem 0.75rem;
  font-family: var(--bt-font-mono);
  font-size: 0.8125rem;
  color: var(--bt-terminal-white-muted);
  background: var(--bt-terminal-tab-bg);
  border: none;
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease;
}

.install-command__tab:hover {
  color: var(--bt-terminal-cyan);
  background: var(--bt-terminal-tab-hover);
}

.install-command__tab[aria-selected='true'] {
  color: var(--bt-terminal-cyan);
  background: var(--bt-terminal-panel);
}

.install-command__panel {
  position: relative;
  display: flex;
  align-items: stretch;
  border: 1px solid var(--bt-terminal-border);
  border-radius: 0 0 8px 8px;
  background: var(--bt-terminal-panel);
  box-shadow: 0 6px 24px rgba(0, 0, 0, 0.22);
}

.install-command__pre {
  margin: 0;
  flex: 1;
  padding: 1rem 1.25rem;
  padding-right: 5rem;
  overflow-x: auto;
  font-family: var(--bt-font-mono);
  font-size: clamp(0.75rem, 2vw, 0.9375rem);
  line-height: 1.5;
  color: var(--bt-terminal-green);
  background: transparent;
}

.install-command__pre code {
  font-family: inherit;
  color: inherit;
}

.install-command__copy {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  padding: 0.35rem 0.65rem;
  font-family: var(--bt-font-mono);
  font-size: 0.75rem;
  color: var(--bt-terminal-cyan);
  background: var(--bt-terminal-tab-bg);
  border: 1px solid var(--bt-terminal-border);
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.15s ease, border-color 0.15s ease;
}

.install-command__copy:hover {
  background: var(--bt-terminal-tab-hover);
  border-color: var(--bt-terminal-cyan);
}
</style>
