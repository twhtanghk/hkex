moment = require 'moment'
{HKEXNew, HKEXNewCron, reverse} = require('../index.coffee')

hkex = new HKEXNew()

do ->
  for await i from reverse hkex.iterAll()
    console.log i

new HKEXNewCron()
  .on 'data', console.log
