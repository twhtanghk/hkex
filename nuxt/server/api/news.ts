import {HKEXNew, reverse} from '/usr/src/app/hkex/index.js'

let news = new HKEXNew()

let match = (pattern, {typeDetail, type, title}) => {
  let r = new RegExp(pattern)
  return r.test(typeDetail) || r.test(type) || r.test(title)
}

export default defineEventHandler(async (event) => {
  const {filter} = getQuery(event)
  let res = []
  for await (const i of reverse(news.iter())) {
    if (match(filter, i))
      res.push(i)
  }
  return res
})
