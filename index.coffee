_ = require 'lodash'
Promise = require 'bluebird'
http = Promise.promisifyAll require 'needle'
http.defaults mode: 'no-cors'
cheerio = require 'cheerio'
moment = require 'moment'
entities = require 'entities'

row = (el) ->
  ret = cheerio('td', el).toArray()
  type = cheerio('span:first-child', ret[3]).text().split('-')
  file = /\((.*), (.*)\)/.exec cheerio('span:last-child', ret[3]).text()

  releasedAt: moment(cheerio('span', ret[0]).text(), 'DD/MM/YYYYHHmm').toDate()
  code: cheerio('span', ret[1]).html()?.split('<br>').join(',')
  name:  entities.decodeHTML(cheerio('span', ret[2]).html()).split('<br>').join(',')
  type: type[0]?.trim()
  typeDetail: type[1]?.trim()
  title: cheerio('a', ret[3]).text()
  link: cheerio('a', ret[3]).attr 'href'
  size: if _.isArray file then file[1] else null

table = (el) ->
  if pageCount(el) == ''
    return []

  cheerio('table#ctl00_gvMain tr:not([class])', el)
    .toArray()
    .map (tr) ->
      if cheerio('td', tr).toArray().length == 4
        row tr

pageCount = (el) ->
  cheerio('span#ctl00_lblDisplay', el).text()

params = (el, firstPage = false) ->
  keys = [
    '__VIEWSTATE'
    '__VIEWSTATEENCRYPTED'
  ]
  if firstPage
    keys = keys.concat [
      'ctl00$txt_today'
      'ctl00$hfStatus'
      'ctl00$hfAlert'
      'ctl00$txt_stock_code'
      'ctl00$txt_stock_name'
      'ctl00$rdo_SelectDocType'
      'ctl00$sel_tier_1'
      'ctl00$sel_DocTypePrior2006'
      'ctl00$sel_tier_2_group'
      'ctl00$sel_tier_2'
      'ctl00$ddlTierTwo'
      'ctl00$ddlTierTwoGroup'
      'ctl00$txtKeyWord'
      'ctl00$rdo_SelectDateOfRelease'
      'ctl00$sel_DateOfReleaseFrom_d'
      'ctl00$sel_DateOfReleaseFrom_m'
      'ctl00$sel_DateOfReleaseFrom_y'
      'ctl00$sel_DateOfReleaseTo_d'
      'ctl00$sel_DateOfReleaseTo_m'
      'ctl00$sel_DateOfReleaseTo_y'
      'ctl00$sel_defaultDateRange'
      'ctl00$rdo_SelectSortBy'
    ]
  ret = {}
  _.map keys, (key) ->
    selector = if key.match /sel_|ddl/ then "select" else "input"
    ret[key] = cheerio("#{selector}[name='#{key}']", el).val()
  if not firstPage
    ret['ctl00$btnNext.x'] = 1
    ret['ctl00$btnNext.y'] = 1
  return ret

class HKEXNew
  @$urlRoot:
    en: process.env.URLEN || 'http://www3.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx'
    ch: process.env.URLCH || 'http://www3.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main_c.aspx'

  constructor: ({@dtStart, @dtEnd, @lang} = {}) ->
    @lang ?= 'ch'
    @dtStart ?= moment().subtract 1, 'days'
    @dtEnd ?= moment()

  iterPage: ->
    res = await http.getAsync HKEXNew.$urlRoot[@lang]
    @params = params res.body, true
    @params = _.extend @params,
      ctl00$sel_DateOfReleaseFrom_d: @dtStart.format 'DD'
      ctl00$sel_DateOfReleaseFrom_m: @dtStart.format 'MM'
      ctl00$sel_DateOfReleaseFrom_y: @dtStart.format 'YYYY'
      ctl00$sel_DateOfReleaseTo_d: @dtEnd.format 'DD'
      ctl00$sel_DateOfReleaseTo_m: @dtEnd.format 'MM'
      ctl00$sel_DateOfReleaseTo_y: @dtEnd.format 'YYYY'
    hasNext = true
    while hasNext
      res = await http.postAsync HKEXNew.$urlRoot[@lang], @params
      hasNext = cheerio("input[name='ctl00$btnNext']", res.body).length != 0
      yield @$parse res

  iterAll: ->
    for await page from @iterPage()
      for i in page
        yield i

  $parse: (res) ->
    @params = params res.body
    table(res.body)

reverse = (iterator) ->
  {value, done} = await iterator.next()
  if not done
    yield from reverse iterator
  else
    return
  yield value

EventEmitter = require 'events'

class HKEXNewCron extends EventEmitter
  last: null

  constructor: (@crontab) ->
    super()
    @crontab ?= [
      # run per minute for every weekday from 09:00 - 16:00
      "0 */1 9-15 * * * 1-5"
      # run per 30 minute from 00-8:00 or 16:00 - 23:00 for everyday
      "0 */30 0-8,16-23 * * * *"
    ]
    _.map @crontab, (at) =>
      require 'node-schedule'
        .scheduleJob at, =>
          console.log "get news starting from #{@last?.toString()} at #{new Date().toString()}"
          hkex = new HKEXNew dtStart: @last
          for await i from reverse hkex.iterAll()
            releasedAt = moment i.releasedAt
            @last ?= releasedAt
            if @last.isBefore releasedAt
              @emit 'data', i
            @last = moment.max @last, releasedAt

module.exports = {HKEXNew, HKEXNewCron, reverse}
