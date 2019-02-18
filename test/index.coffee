moment = require 'moment'
{HKEXNew, HKEXNewCron, reverse} = require('../index.coffee')
{Writable} = require 'stream'

hkex = new HKEXNew()

do ->
  for await i from reverse hkex.iterAll()
    console.log i

new HKEXNewCron()
  .pipe new Writable objectMode: true, write: (data, encoding, cb) ->
    console.log data
    cb()
