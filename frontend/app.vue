<template>
  <div v-for='i in msgs'>
    {{JSON.stringify(i)}}
  </div>
</template>

<script setup>
import {reactive} from 'vue'
import {HKEXNew, HKEXList, reverse} from '../index.js'

let hkex = new HKEXNew()

const msgs = reactive([])

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
