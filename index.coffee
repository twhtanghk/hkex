_ = require 'lodash'
Promise = require 'bluebird'
http = Promise.promisifyAll require 'needle'
cheerio = require 'cheerio'
moment = require 'moment'
entities = require 'entities'

row = (el) ->
  ret = cheerio('td', el).toArray()
  type = cheerio('span:first-child', ret[3]).text().split('-')
  file = /\((.*), (.*)\)/.exec cheerio('span:last-child', ret[3]).text()

  releasedAt: moment(cheerio('span', ret[0]).text(), 'DD/MM/YYYYHHmm').toDate()
  code: cheerio('span', ret[1]).html().split('<br>').join(',')
  name:  entities.decodeHTML(cheerio('span', ret[2]).html()).split('<br>').join(',')
  type: type[0]?.trim()
  typeDetail: type[1]?.trim()
  title: cheerio('a', ret[3]).text()
  link: cheerio('a', ret[3]).attr 'href'
  size: if _.isArray file then file[1] else null

table = (el) ->
  ret = cheerio('table#ctl00_gvMain tr:not([class])', el)
    .toArray()
    .map row

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
    en: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx'
    ch: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main_c.aspx'

  models: []

  constructor: (@params, @lang = 'en') ->
    return

  hasNext: true

  $fetch: ->
    if not @hasNext
      Promise.resolve @

    http
      .postAsync HKEXNew.$urlRoot[@lang], @params
      .then (res) =>
        @hasNext = cheerio("input[name='ctl00$btnNext']", res.body).length != 0
        @$parse res

  $parse: (res) ->
    @params = params res.body
    _.each table(res.body), (model) =>
      @models.push model
    @

module.exports = (opts = {}) ->
  lang = opts.lang || 'en'
  dtStart = opts.dtStart || moment().subtract(1, 'months')
  dtEnd = moment(dtStart).add(1, 'months')
  now = moment()
  if now.isBefore dtEnd
    dtEnd = now
  http
    .getAsync HKEXNew.$urlRoot[lang]
    .then (res) ->
      data = params(res.body, true)
      data = _.extend data,
        ctl00$sel_DateOfReleaseFrom_d: dtStart.format 'DD'
        ctl00$sel_DateOfReleaseFrom_m: dtStart.format 'MM'
        ctl00$sel_DateOfReleaseFrom_y: dtStart.format 'YYYY'
        ctl00$sel_DateOfReleaseTo_d: dtEnd.format 'DD'
        ctl00$sel_DateOfReleaseTo_m: dtEnd.format 'MM'
        ctl00$sel_DateOfReleaseTo_y: dtEnd.format 'YYYY'
      new HKEXNew data, lang
