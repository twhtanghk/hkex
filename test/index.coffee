{HKEXList, HKEXNew, reverse} = require('../index.coffee')

hkex = new HKEXNew()

do ->
  for await i from reverse hkex.iter()
    console.log i

do ->
  for await row from HKEXList()
    console.log row
