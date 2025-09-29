<template>
  <div>
    <UInput v-model='filter' @keyup.enter.prevent='refresh'/>
  <UTable sticky :data="msgs" :columns="columns">
    <template #code-cell="{row}">
      <ULink :to="chart(row)" target='blank'>
        {{row.original.code}}
      </ULink>
    </template>
    <template #type-cell="{row}">
      <ULink :to="url(row.original.link)" target='blank'>
        {{row.original.type}}
      </ULink>
    </template>
  </UTable>
  </div>
</template>

<script setup>
import {reactive, ref} from 'vue'
import {HKEXNew} from '../index.js'

function chart(row) {
  let code = Number(row.original.code).toString()
  return `https://www.tradingview.com/chart/?symbol=${code}`
}

function url(path) {
  let {origin} = URL.parse(HKEXNew.url({page: 0}))
  return origin + path
}

const msgs = reactive([])
const filter = ref('')
const columns = [
  { accessorKey: 'code', header: 'Code' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'type', header: 'Type' },
  { accessorKey: 'typeDetail', header: 'Detail' },
  { accessorKey: 'title', header: 'Title' },
  { accessorKey: 'releasedAt', header: 'Date' }
]

async function refresh() {
  msgs.splice(0)
  let {data} = await useFetch('/api/news', {query: {filter}})
  for (const i of data.value) {
    msgs.push(i)
  }
}

await refresh()
</script>

<style scoped>
@import "tailwindcss";
@import "@nuxt/ui";
</style>
