import {HKEXNew, reverse} from '/usr/src/app/hkex/index.js'

let news = new HKEXNew()

let match = ({typeDetail, type, title}) => {
  let pattern = new RegExp(process.env.ALERT)
  return pattern.test(typeDetail) || pattern.test(type) || pattern.test(title)
}

export default defineEventHandler(async (event) => {
  let res = []
  for await (const i of reverse(news.iter())) {
    if (match(i))
      res.push(i)
  }
  return res
})
