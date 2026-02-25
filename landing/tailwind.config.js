/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{vue,ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        'dark-space':  '#0a0a0f',
        'dark-card':   '#13131a',
        'dark-border': '#1e1e2e',
        'neon-cyan':   '#00f5ff',
        'neon-purple': '#9d4edd',
      },
      fontFamily: {
        mono: ['"JetBrains Mono"', '"Fira Code"', 'monospace'],
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'fade-up':    'fadeUp 0.7s ease-out forwards',
        'glow':       'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        fadeUp: {
          '0%':   { opacity: '0', transform: 'translateY(24px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        glow: {
          '0%':   { boxShadow: '0 0 5px #00f5ff44, 0 0 10px #00f5ff22' },
          '100%': { boxShadow: '0 0 20px #00f5ff88, 0 0 40px #00f5ff44' },
        },
      },
    },
  },
  plugins: [],
}
