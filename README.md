# Web scraper for HKEX latest listed company information

## Install
```
npm install hkex
```

## Usage
language options 'en' or 'ch' for initialization
```
hkex = require('hkex')('ch')
hkex
  .then (hkex) ->
    hkex.$fetch()
  .then (hkex) ->
    hkex.$fetch()
  .then (hkex) ->
    console.log hkex.models
```
