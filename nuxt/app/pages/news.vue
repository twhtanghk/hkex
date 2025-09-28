<template>
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
</template>

<script setup>
import {reactive} from 'vue'
import {HKEXNew} from '../index.js'

function chart(row) {
  let code = Number(row.original.code).toString()
  return `https://www.tradingview.com/chart/?symbol=${code}`
}

function url(path) {
  let a = URL.parse(HKEXNew.url({page: 0}))
  return a.origin + path
}

const msgs = reactive([])
const columns = [
  { accessorKey: 'code', header: 'Code' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'type', header: 'Type' },
  { accessorKey: 'typeDetail', header: 'Detail' },
  { accessorKey: 'title', header: 'Title' },
  { accessorKey: 'releasedAt', header: 'Date' }
]

let {data} = await useFetch('/api/news')
for (const i of data.value) {
  msgs.push(i)
}
</script>

<style scoped>
@import "tailwindcss";
@import "@nuxt/ui";
</style>
