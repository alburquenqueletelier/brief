<script setup lang="ts">
import type { Project } from '@/types/project'

defineProps<{ project: Project }>()

const statusLabel: Record<string, string> = {
  'live':        'live',
  'in-progress': 'en desarrollo',
  'archived':    'archivado',
}
</script>

<template>
  <a
    :href="project.url"
    target="_blank"
    rel="noopener noreferrer"
    class="glass-card p-6 block group
           hover:border-neon-cyan/40 hover:-translate-y-1
           hover:shadow-[0_0_32px_rgba(0,245,255,0.08)]
           transition-all duration-300"
  >
    <!-- Header -->
    <div class="flex items-start justify-between gap-3 mb-3">
      <h3 class="text-white font-semibold text-lg group-hover:text-neon-cyan transition-colors duration-200">
        {{ project.name }}
      </h3>
      <span
        class="shrink-0 px-2 py-0.5 rounded-full font-mono text-xs border"
        :class="{
          'text-emerald-400 bg-emerald-400/10 border-emerald-400/20': project.status === 'live',
          'text-amber-400  bg-amber-400/10  border-amber-400/20':     project.status === 'in-progress',
          'text-gray-500   bg-gray-500/10   border-gray-500/20':      project.status === 'archived',
        }"
      >
        {{ statusLabel[project.status] }}
      </span>
    </div>

    <!-- Descripción -->
    <p class="text-gray-400 text-sm leading-relaxed mb-5">
      {{ project.description }}
    </p>

    <!-- Tags -->
    <div class="flex flex-wrap gap-2">
      <span
        v-for="tag in project.tags"
        :key="tag"
        class="px-2 py-0.5 rounded font-mono text-xs
               bg-dark-space text-gray-500 border border-dark-border"
      >
        {{ tag }}
      </span>
    </div>

    <!-- Arrow -->
    <div class="mt-5 flex items-center gap-1 text-neon-cyan/40 text-xs font-mono
                group-hover:text-neon-cyan/80 transition-colors duration-200">
      <span>{{ project.url.replace('https://', '') }}</span>
      <svg class="w-3 h-3 group-hover:translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
      </svg>
    </div>
  </a>
</template>
