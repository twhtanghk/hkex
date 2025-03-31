<template>
  <UApp>
    <NuxtPage>
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
    </NuxtPage>
  </UApp>
</template>

<script setup>
import {reactive} from 'vue'
import {HKEXNew, HKEXList, reverse} from '../index.js'

let hkex = new HKEXNew()

const msgs = reactive([])
const columns = [
  { accessorKey: 'code', header: 'Code' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'type', header: 'Type' },
  { accessorKey: 'typeDetail', header: 'Detail' },
  { accessorKey: 'title', header: 'Title' },
  { accessorKey: 'releasedAt', header: 'Date' }
]

function chart(row) {
  let code = Number(row.original.code).toString()
  return `https://www.tradingview.com/chart/?symbol=${code}`
}

function url(path) {
  let a = URL.parse(HKEXNew.url({page: 0}))
  return a.origin + path
}

function match({typeDetail, type, title}) {
  let pattern = new RegExp(process.env.ALERT)
  return pattern.test(typeDetail) || pattern.test(type) || pattern.test(title)
}

async function news() {
  for await (const i of hkex.iter()) {
    if (match(i))
      msgs.push(i)
  }
}

await news()
</script>

<style scoped>
@import "tailwindcss";
@import "@nuxt/ui";
</style>
