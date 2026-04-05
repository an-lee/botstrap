<script setup lang="ts">
const short = __DOCS_COMMIT_SHORT__
const full = __DOCS_COMMIT_FULL__
const commitHref =
  full.length > 0
    ? `https://github.com/an-lee/botstrap/commit/${full}`
    : null
</script>

<template>
  <p class="docs-site-version">
    <span class="docs-site-version__label">Docs build:</span>
    <a
      v-if="commitHref"
      class="docs-site-version__hash"
      :href="commitHref"
      rel="noopener noreferrer"
      target="_blank"
    >{{ short }}</a>
    <span v-else class="docs-site-version__hash">{{ short }}</span>
  </p>
</template>

<style scoped>
.docs-site-version {
  margin: 0.5rem 0 0;
  font-family: var(--bt-font-mono);
  font-size: 0.8125rem;
  color: var(--bt-terminal-white-muted);
}

.docs-site-version__label {
  margin-right: 0.35rem;
}

.docs-site-version__hash {
  color: var(--bt-terminal-cyan);
  text-decoration: none;
}

a.docs-site-version__hash:hover {
  text-decoration: underline;
}
</style>
