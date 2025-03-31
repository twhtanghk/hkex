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
  },
  /*
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
  target: 'static',
  ssr: false
  */
})
