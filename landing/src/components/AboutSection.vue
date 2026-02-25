<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useIntersectionObserver } from '@vueuse/core'

const section = ref<HTMLElement | null>(null)
const visible = ref(false)

onMounted(() => {
  useIntersectionObserver(
    section,
    ([entry]) => { if (entry?.isIntersecting) visible.value = true },
    { threshold: 0.15 },
  )
})

const categories = [
  {
    label: 'Backend',
    color: 'cyan',
    items: ['Python', 'FastAPI', 'Django', 'Flask', 'SQLAlchemy', 'Alembic', 'C', 'C#'],
  },
  {
    label: 'Frontend',
    color: 'purple',
    items: ['TypeScript', 'React', 'NextJs', 'Vue 3', 'Vite', 'Tailwind CSS'],
  },
  {
    label: 'Datos & Mensajería',
    color: 'cyan',
    items: ['PostgreSQL', 'Redis'],
  },
  {
    label: 'Infraestructura',
    color: 'purple',
    items: ['Docker', 'Nginx', 'Linux', 'Git'],
  },
  {
    label: 'Cloud',
    color: 'cyan',
    items: ['Azure', 'Google Cloud'],
  },
  {
    label: 'IA / LLM',
    color: 'purple',
    items: ['Gemini API'],
  },
]
</script>

<template>
  <section id="about" ref="section" class="py-32 px-6">
    <div
      class="max-w-3xl mx-auto transition-all duration-700"
      :class="visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'"
    >
      <span class="section-label">// Sobre mí</span>

      <h2 class="text-3xl sm:text-4xl font-bold text-white mb-8">
        Desarrollo software que
        <span class="neon-text"> resuelve necesidades reales</span>
      </h2>

      <div class="space-y-4 text-gray-400 text-base leading-relaxed mb-14">
        <p>
          Soy desarrollador de software con foco en backend y sistemas distribuidos.
          Me interesa construir herramientas que resuelvan problemas reales,
          con arquitecturas limpias y código que sea fácil de mantener.
        </p>
        <p>
          Trabajo principalmente con Python y FastAPI para APIs, React/NextJs para frontends,
          y Docker para desplegar todo de forma reproducible.
          Me gusta entender el sistema completo, desde la DB hasta el proxy.
        </p>
      </div>

      <!-- Stack categorizado -->
      <div class="space-y-5">
        <p class="font-mono text-xs text-gray-600 tracking-widest uppercase">stack</p>

        <div
          v-for="cat in categories"
          :key="cat.label"
          class="grid grid-cols-[120px_1fr] sm:grid-cols-[150px_1fr] items-start gap-3"
        >
          <span
            class="font-mono text-xs pt-1 tracking-wide"
            :class="cat.color === 'cyan' ? 'text-neon-cyan/60' : 'text-neon-purple/60'"
          >
            {{ cat.label }}
          </span>

          <div class="flex flex-wrap gap-2">
            <span
              v-for="item in cat.items"
              :key="item"
              class="px-2.5 py-1 rounded-md font-mono text-xs border transition-colors duration-200"
              :class="cat.color === 'cyan'
                ? 'bg-neon-cyan/5 text-gray-300 border-neon-cyan/15 hover:bg-neon-cyan/10 hover:text-neon-cyan hover:border-neon-cyan/30'
                : 'bg-neon-purple/5 text-gray-300 border-neon-purple/15 hover:bg-neon-purple/10 hover:text-neon-purple hover:border-neon-purple/30'"
            >
              {{ item }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
