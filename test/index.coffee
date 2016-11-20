hkex = require('../index.coffee')('ch')

get = (page = 0) ->
  hkex
    .then (data) ->
      console.log page
      console.log data.models
      data.models = []
      hkex = data.$fetch()
      get(page + 1)

get()
