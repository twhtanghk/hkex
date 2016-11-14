hkex = require('../index.coffee')('ch')

hkex
  .then (hkex) ->
    hkex.$fetch()
  .then (hkex) ->
    hkex.$fetch()
  .then (hkex) ->
    console.log hkex.models
