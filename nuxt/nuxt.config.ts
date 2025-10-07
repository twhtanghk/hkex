// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxt/ui'],
  build: {
    commonjsOptions: {
       include: [/node_modules/],
        transformMixedEsModules: true
    }
  },
  experimental: {
    clientNodeCompat: true
  },
  vite: {
    define: {
      "process.version": "navigator.userAgent",
      "process.platform": "navigator.userAgent",
      "process.arch": "navigator.userAgent",
      "stream.PassThrough": "TransformStream"
    }
  },
/*  target: 'static', */
  ssr: false
})
