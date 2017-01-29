moment = require 'moment'
hkex = require('../index.coffee')
  lang: 'ch'
  dtStart: moment()

get = ->
  hkex
    .then (data) ->
      if data.hasNext
        hkex = data.$fetch()
        return get()
      console.log data.models

get()
