{HKEXList, HKEXNew, reverse} = require('../index.coffee')

hkex = new HKEXNew()

match = ({typeDetail, type, title}) ->
  pattern = new RegExp process.env.ALERT
  pattern.test(typeDetail) or
  pattern.test(type) or
  pattern.test(title)
  
do ->
  for await i from reverse hkex.iter()
    if match i
      console.log i

do ->
  for await row from HKEXList()
    console.log row
