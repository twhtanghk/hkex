# Web scraper for HKEX latest listed company information

## Install
```
npm install hkex
```

## Usage
language options 'en' or 'ch' for initialization
```
moment = require 'moment'
hkex = require('hkex')
  lang: 'ch'
  dtStart: moment()

get = (page = 0) ->
  hkex
    .then (data) ->
      console.log page
      console.log data.models
      data
    .then (data) ->
      data.models = []
      hkex = data.$fetch()
      if data.hasNext
        get(page + 1)

get()
```
