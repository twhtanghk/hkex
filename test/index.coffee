moment = require 'moment'
hkex = require('../index.coffee')
do ->
  for await i from hkex(lang: 'ch', dtStart: moment().subtract(1, 'days'))
    console.log i
