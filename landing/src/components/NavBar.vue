<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const scrolled = ref(false)

function onScroll() {
  scrolled.value = window.scrollY > 40
}

onMounted(() => window.addEventListener('scroll', onScroll))
onUnmounted(() => window.removeEventListener('scroll', onScroll))

const links = [
  { label: 'inicio',    href: '#hero' },
  { label: 'sobre mí', href: '#about' },
  { label: 'proyectos', href: '#projects' },
]
</script>

<template>
  <nav
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
    :class="scrolled
      ? 'bg-dark-space/90 backdrop-blur-md border-b border-dark-border'
      : 'bg-transparent'"
  >
    <div class="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
      <a href="#hero" class="font-mono text-sm text-neon-cyan tracking-widest hover:opacity-80 transition-opacity">
        alburquenque.net
      </a>
      <div class="hidden sm:flex items-center gap-8">
        <a
          v-for="link in links"
          :key="link.href"
          :href="link.href"
          class="font-mono text-xs text-gray-400 tracking-widest uppercase
                 hover:text-neon-cyan transition-colors duration-200"
        >
          {{ link.label }}
        </a>
      </div>
    </div>
  </nav>
</template>
