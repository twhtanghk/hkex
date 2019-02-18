moment = require 'moment'
{HKEXNew, HKEXNewCron, HKEXNewAlert, HKEXNewMqtt, reverse} = require('../index.coffee')
{Writable} = require 'stream'

hkex = new HKEXNew()

do ->
  for await i from reverse hkex.iterAll()
    console.log i

new HKEXNewCron()
  .pipe new HKEXNewAlert()
  .pipe new HKEXNewMqtt()
  .pipe new Writable objectMode: true, write: (data, encoding, cb) ->
    console.log data
    cb()
