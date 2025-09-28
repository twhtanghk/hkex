<template>
  <UTable sticky :data="list" :columns="columns">
    <template #code-cell="{row}">
      <ULink :to="chart(row)" target='blank'>
        {{row.original.code}}
      </ULink>
    </template>
  </UTable>
</template>

<script setup>
import {reactive} from 'vue'

function chart(row) {
  let code = Number(row.original.code).toString()
  return `https://www.tradingview.com/chart/?symbol=${code}`
}

const list = reactive([])
const columns = [
  { accessorKey: 'code', header: 'Code' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'delta', header: 'Delta' },
  { accessorKey: 'close', header: 'Close' },
  { accessorKey: 'close.mean', header: 'Close (mean)' },
  { accessorKey: 'close.stdev', header: 'Close (stdev)' },
  { accessorKey: 'close.trend', header: 'Close (trend)' },
  { accessorKey: 'volume', header: 'Volume' },
  { accessorKey: 'volume.mean', header: 'Volume (mean)' },
  { accessorKey: 'volume.stdev', header: 'Volume (stdev)' },
  { accessorKey: 'volume.trend', header: 'Volume (trend)' },
  { accessorKey: 'timestamp', header: 'Time' }
]

let {data} = await useFetch('/api/hsi')
for (const i of data.value) {
  list.push(i)
}
</script>

<style scoped>
@import "tailwindcss";
@import "@nuxt/ui";
</style>
