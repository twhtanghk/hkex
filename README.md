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

get = ->
  hkex
    .then (data) ->
      if data.hasNext
        hkex = data.$fetch()
        return get()
      console.log data.models

get()
```
