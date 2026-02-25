<script setup lang="ts">
import NavBar from '@/components/NavBar.vue'
import HeroSection from '@/components/HeroSection.vue'
import AboutSection from '@/components/AboutSection.vue'
import ProjectsSection from '@/components/ProjectsSection.vue'
</script>

<template>
  <div class="min-h-screen bg-dark-space">
    <NavBar />
    <main>
      <HeroSection />
      <AboutSection />
      <ProjectsSection />
    </main>

    <!-- Footer -->
    <footer class="border-t border-dark-border py-8 px-6 text-center">
      <p class="font-mono text-xs text-gray-600 tracking-widest">
        alburquenque.net &mdash; {{ new Date().getFullYear() }}
      </p>
    </footer>
  </div>
</template>
