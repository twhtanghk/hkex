_ = require 'lodash'
http = require 'needle'

class HKEXNew
  @url: _.template process.env.URL || 'https://www1.hkexnews.hk/ncms/json/eds/lcisehk1relsdc_<%=page%>.json'

  iter: ->
    for i in [1..5]
      res = await http 'get', HKEXNew.url page: i
      for alert in res.body.newsInfoLst
        yield alert

reverse = (iterator) ->
  {value, done} = await iterator.next()
  if not done
    yield from reverse iterator
  else
    return
  yield value

module.exports = {HKEXNew, reverse}
