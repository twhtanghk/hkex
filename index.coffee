_ = require 'lodash'
Promise = require 'bluebird'
http = Promise.promisifyAll require 'needle'
cheerio = require 'cheerio'
url =
  en: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx'
  tc: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main_c.aspx'
  sc: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main_c.aspx'

row = (el) ->
  ret = cheerio('td', el).toArray()
  date: cheerio('span', ret[0]).text()
  code: cheerio('span', ret[1]).text()
  name:  cheerio('span', ret[2]).text()
  doc: 
    type: cheerio('span:first-child', ret[3]).text()
    name: cheerio('a', ret[3]).text()
    link: cheerio('a', ret[3]).attr 'href'
    size: cheerio('span:last-child', ret[3]).text()

table = (el) ->
  ret = cheerio('table#ctl00_gvMain tr:not([class])', el)
    .toArray()
    .map row

formData = (el, firstPage = false) ->
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

page = (data, lang = 'en') ->
  http.postAsync url.en, data 
    .then (res) ->
      records: table res.body
      data: formData res.body

http
  .getAsync url['en']
  .then (res) ->
    data: formData res.body, true
  .then (res) ->
    page res.data
  .then (res) ->
    page res.data
  .then (res) ->
    console.log res.records
  .catch console.log
