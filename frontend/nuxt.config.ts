// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: ['@nuxt/ui'],
  server: {
    host: '0'
  },
  build: {
    commonjsOptions: {
       include: ['../index.js', /node_modules/],
        transformMixedEsModules: true
    }
  }
})
