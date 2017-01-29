// Generated by CoffeeScript 1.11.1
(function() {
  var HKEXNew, Promise, _, cheerio, entities, http, moment, pageCount, params, row, table;

  _ = require('lodash');

  Promise = require('bluebird');

  http = Promise.promisifyAll(require('needle'));

  http.defaults({
    mode: 'no-cors'
  });

  cheerio = require('cheerio');

  moment = require('moment');

  entities = require('entities');

  row = function(el) {
    var file, ref, ref1, ref2, ret, type;
    ret = cheerio('td', el).toArray();
    type = cheerio('span:first-child', ret[3]).text().split('-');
    file = /\((.*), (.*)\)/.exec(cheerio('span:last-child', ret[3]).text());
    return {
      releasedAt: moment(cheerio('span', ret[0]).text(), 'DD/MM/YYYYHHmm').toDate(),
      code: (ref = cheerio('span', ret[1]).html()) != null ? ref.split('<br>').join(',') : void 0,
      name: entities.decodeHTML(cheerio('span', ret[2]).html()).split('<br>').join(','),
      type: (ref1 = type[0]) != null ? ref1.trim() : void 0,
      typeDetail: (ref2 = type[1]) != null ? ref2.trim() : void 0,
      title: cheerio('a', ret[3]).text(),
      link: cheerio('a', ret[3]).attr('href'),
      size: _.isArray(file) ? file[1] : null
    };
  };

  table = function(el) {
    if (pageCount(el) === '') {
      return [];
    }
    return cheerio('table#ctl00_gvMain tr:not([class])', el).toArray().map(function(tr) {
      if (cheerio('td', tr).toArray().length === 4) {
        return row(tr);
      }
    });
  };

  pageCount = function(el) {
    return cheerio('span#ctl00_lblDisplay', el).text();
  };

  params = function(el, firstPage) {
    var keys, ret;
    if (firstPage == null) {
      firstPage = false;
    }
    keys = ['__VIEWSTATE', '__VIEWSTATEENCRYPTED'];
    if (firstPage) {
      keys = keys.concat(['ctl00$txt_today', 'ctl00$hfStatus', 'ctl00$hfAlert', 'ctl00$txt_stock_code', 'ctl00$txt_stock_name', 'ctl00$rdo_SelectDocType', 'ctl00$sel_tier_1', 'ctl00$sel_DocTypePrior2006', 'ctl00$sel_tier_2_group', 'ctl00$sel_tier_2', 'ctl00$ddlTierTwo', 'ctl00$ddlTierTwoGroup', 'ctl00$txtKeyWord', 'ctl00$rdo_SelectDateOfRelease', 'ctl00$sel_DateOfReleaseFrom_d', 'ctl00$sel_DateOfReleaseFrom_m', 'ctl00$sel_DateOfReleaseFrom_y', 'ctl00$sel_DateOfReleaseTo_d', 'ctl00$sel_DateOfReleaseTo_m', 'ctl00$sel_DateOfReleaseTo_y', 'ctl00$sel_defaultDateRange', 'ctl00$rdo_SelectSortBy']);
    }
    ret = {};
    _.map(keys, function(key) {
      var selector;
      selector = key.match(/sel_|ddl/) ? "select" : "input";
      return ret[key] = cheerio(selector + "[name='" + key + "']", el).val();
    });
    if (!firstPage) {
      ret['ctl00$btnNext.x'] = 1;
      ret['ctl00$btnNext.y'] = 1;
    }
    return ret;
  };

  HKEXNew = (function() {
    HKEXNew.$urlRoot = {
      en: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main.aspx',
      ch: 'http://www.hkexnews.hk/listedco/listconews/advancedsearch/search_active_main_c.aspx'
    };

    HKEXNew.prototype.models = [];

    function HKEXNew(params1, lang1) {
      this.params = params1;
      this.lang = lang1 != null ? lang1 : 'en';
      return;
    }

    HKEXNew.prototype.hasNext = true;

    HKEXNew.prototype.$fetch = function() {
      return http.postAsync(HKEXNew.$urlRoot[this.lang], this.params).then((function(_this) {
        return function(res) {
          _this.hasNext = cheerio("input[name='ctl00$btnNext']", res.body).length !== 0;
          return _this.$parse(res);
        };
      })(this));
    };

    HKEXNew.prototype.$parse = function(res) {
      this.params = params(res.body);
      _.each(table(res.body), (function(_this) {
        return function(model) {
          return _this.models.push(model);
        };
      })(this));
      return this;
    };

    return HKEXNew;

  })();

  module.exports = function(opts) {
    var dtEnd, dtStart, lang, now;
    if (opts == null) {
      opts = {};
    }
    lang = opts.lang || 'en';
    dtStart = opts.dtStart || moment().subtract(1, 'months');
    dtEnd = moment(dtStart).add(1, 'months');
    now = moment();
    if (now.isBefore(dtEnd)) {
      dtEnd = now;
    }
    return http.getAsync(HKEXNew.$urlRoot[lang]).then(function(res) {
      var data;
      data = params(res.body, true);
      data = _.extend(data, {
        ctl00$sel_DateOfReleaseFrom_d: dtStart.format('DD'),
        ctl00$sel_DateOfReleaseFrom_m: dtStart.format('MM'),
        ctl00$sel_DateOfReleaseFrom_y: dtStart.format('YYYY'),
        ctl00$sel_DateOfReleaseTo_d: dtEnd.format('DD'),
        ctl00$sel_DateOfReleaseTo_m: dtEnd.format('MM'),
        ctl00$sel_DateOfReleaseTo_y: dtEnd.format('YYYY')
      });
      return new HKEXNew(data, lang);
    });
  };

}).call(this);
