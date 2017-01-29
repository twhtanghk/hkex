moment = require 'moment'
hkex = require('../index.coffee')
  lang: 'ch'
  dtStart: moment().subtract(2, 'd')

get = () ->
  hkex
    .then (data) ->
      if data.hasNext
        hkex = data.$fetch()
        get()
      else
        console.log data.models

get()
