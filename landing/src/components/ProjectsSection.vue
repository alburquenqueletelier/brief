<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useIntersectionObserver } from '@vueuse/core'
import ProjectCard from '@/components/ProjectCard.vue'
import { projects } from '@/types/project'

const section = ref<HTMLElement | null>(null)
const visible = ref(false)

onMounted(() => {
  useIntersectionObserver(
    section,
    ([entry]) => { if (entry?.isIntersecting) visible.value = true },
    { threshold: 0.1 },
  )
})
</script>

<template>
  <section id="projects" ref="section" class="py-32 px-6 pb-40">
    <div class="max-w-3xl mx-auto">
      <div
        class="transition-all duration-700"
        :class="visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'"
      >
        <span class="section-label">// proyectos</span>

        <h2 class="text-3xl sm:text-4xl font-bold text-white mb-3">
          Soluciones Destacadas
        </h2>
        <!-- <p class="text-gray-500 text-sm font-mono mb-12">
          Cada proyecto corre en su propio subdominio ↗
        </p> -->
      </div>

      <div class="grid gap-5 sm:grid-cols-2">
        <ProjectCard
          v-for="(project, i) in projects"
          :key="project.id"
          :project="project"
          class="transition-all duration-700"
          :class="visible
            ? 'opacity-100 translate-y-0'
            : 'opacity-0 translate-y-8'"
          :style="{ transitionDelay: `${i * 100 + 150}ms` }"
        />
      </div>
    </div>
  </section>
</template>
