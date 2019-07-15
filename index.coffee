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

module.exports = {HKEXNew, reverse}
