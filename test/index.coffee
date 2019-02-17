moment = require 'moment'
HKEXNew = require('../index.coffee')
hkex = new HKEXNew
  lang: 'ch'
  dtStart: moment().subtract(1, 'days')

do ->
  for await i from hkex.iterAll()
    console.log i
