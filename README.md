# Web scraper for HKEX latest listed company information

## Install
```
npm install hkex
```

## Usage
language options 'en' or 'ch' for initialization
```
hkex = require('hkex')('ch')

get = (page = 0) ->
  hkex
    .then (data) ->
      console.log page
      console.log data.models
      data.models = []
      hkex = data.$fetch()
      get(page + 1)

get()
```
