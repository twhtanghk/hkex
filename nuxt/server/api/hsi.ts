import {HKEXList} from '/usr/src/app/hkex/index.js'

export default defineEventHandler(async (event) => {
  let res = []
  let list = (await HKEXList())
  for await (const i of list) {
    res.push(i)
  }
  return res
})
