<script setup lang="ts">
import { ref, onMounted } from 'vue'

const visible = ref(false)
onMounted(() => {
  requestAnimationFrame(() => { visible.value = true })
})
</script>

<template>
  <section id="hero" class="relative min-h-screen flex items-center justify-center overflow-hidden">

    <!-- Grid background -->
    <div
      class="absolute inset-0 pointer-events-none"
      style="
        background-image:
          linear-gradient(rgba(0,245,255,0.04) 1px, transparent 1px),
          linear-gradient(90deg, rgba(0,245,255,0.04) 1px, transparent 1px);
        background-size: 72px 72px;
      "
    />

    <!-- Orbs de luz -->
    <div class="absolute top-1/3 left-1/4 w-[500px] h-[500px] rounded-full
                bg-neon-cyan/5 blur-[140px] animate-pulse-slow pointer-events-none" />
    <div class="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] rounded-full
                bg-neon-purple/5 blur-[120px] animate-pulse-slow pointer-events-none" />

    <!-- Contenido -->
    <div
      class="relative z-10 text-center px-6 max-w-3xl mx-auto transition-all duration-700"
      :class="visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'"
    >
      <span class="section-label">&gt; Hello, World_</span>

      <h1 class="text-5xl sm:text-6xl md:text-7xl font-bold text-white leading-tight mb-4">
        Bryan Alburquenque
      </h1>

      <p class="text-xl sm:text-2xl font-mono text-neon-cyan mb-6 tracking-wide">
        Software Engineer
      </p>

      <p class="text-gray-400 text-base sm:text-lg max-w-xl mx-auto mb-10 leading-relaxed">
        Te ayudo a potenciar tu negocio con tecnología de vanguardia para que te mantengas enfocado en lo que realmente importa.
      </p>

      <div class="flex gap-4 justify-center flex-wrap">
        <a href="#projects" class="btn-primary">Ver proyectos</a>
        <a href="#about" class="btn-outline">Sobre mí</a>
      </div>

      <!-- Indicadores de tecnología -->
      <div class="mt-10 flex items-center justify-center gap-2 flex-wrap">
        <span class="font-mono text-xs text-gray-600 tracking-widest mr-1">con</span>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full
                     border border-neon-purple/25 bg-neon-purple/5
                     font-mono text-xs text-neon-purple/70">
          <svg class="w-3 h-3" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
          Gemini API
        </span>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full
                     border border-neon-cyan/25 bg-neon-cyan/5
                     font-mono text-xs text-neon-cyan/70">
          <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/>
          </svg>
          Azure
        </span>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full
                     border border-neon-purple/25 bg-neon-purple/5
                     font-mono text-xs text-neon-purple/70">
          <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M4.22 4.22l2.12 2.12M17.66 17.66l2.12 2.12M2 12h3M19 12h3M4.22 19.78l2.12-2.12M17.66 6.34l2.12-2.12"/>
          </svg>
          Google Cloud
        </span>
      </div>
    </div>

    <!-- Indicador de scroll -->
    <div
      class="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-1
             opacity-40 animate-bounce"
    >
      <span class="font-mono text-xs text-gray-500 tracking-widest">scroll</span>
      <svg class="w-4 h-4 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  </section>
</template>
