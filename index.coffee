_ = require 'lodash'
http = require 'needle'
moment = require 'moment'

class HKEXNew
  @url: _.template process.env.URL || 'https://www1.hkexnews.hk/ncms/json/eds/lcisehk1relsdc_<%=page%>.json'

  iter: ->
    for i in [1..5]
      res = await http 'get', HKEXNew.url page: i
      for alert in res.body.newsInfoLst
        type = alert.lTxt.split ' - '
        yield
          releasedAt: moment(alert.relTime, 'DD-MM-YYYY HH:mm').toDate()
          code: alert.stock[0].sc
          name: alert.stock[0].sn
          type: type[0]
          typeDetail: type[1]
          title: alert.title
          link: alert.webPath
          size: alert.size

reverse = (iterator) ->
  {value, done} = await iterator.next()
  if not done
    yield from reverse iterator
  else
    return
  yield value

XLSX = require 'xlsx'
{Transform} = require 'stream'

range = (sheet) ->
  pattern = /([A-Z]+)([0-9]+)/
  cells = _.filter _.keys(sheet), (key) ->
    pattern.test key
  row = _.max _.map cells, (key) ->
    ret = key.match pattern
    parseInt ret[2]
  col = _.max _.map cells, (key) ->
    ret = key.match pattern
    ret[1]
  return "A4:#{col}#{row}"

class Buffer extends Transform
  buffer: []

  constructor: (opts = {readableObjectMode: true, writableObjectMode: true}) ->
    super opts
  
  _transform: (data, encoding, cb) ->
    @buffer.push data
    cb()

  end: ->
    data = require('buffer').Buffer.concat(@buffer)
    {Sheets} = XLSX.read data, type: 'buffer'
    opts =
      range: range Sheets.ListOfSecurities
      header: [
        'code'
        'name'
        'category'
        'sub-category'
        'lot'
        'value'
        'isin'
        'expiry date'
        'stamp duty'
        'shortsell eligible'
        'cas eligible'
        'vcm eligible'
        'stock options'
        'stock futures'
        'ccass'
        'etf'
        'debt securities board lot'
        'debt securities investor type'
      ]
    for row in XLSX.utils.sheet_to_json Sheets.ListOfSecurities, opts
      @push row
    @

HKEXList = ->
  http.get process.env.STOCKLIST || 'https://www.hkex.com.hk/chi/services/trading/securities/securitieslists/ListOfSecurities_c.xlsx'
    .pipe new Buffer()

module.exports = {HKEXList, HKEXNew, reverse}
