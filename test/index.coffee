moment = require 'moment'
hkex = require('../index.coffee')
  lang: 'ch'
  dtStart: moment()

get = (page = 0) ->
  hkex
    .then (data) ->
      console.log page
      console.log data.models
      data.models = []
      hkex = data.$fetch()
      if data.hasNext
        get(page + 1)

get()
