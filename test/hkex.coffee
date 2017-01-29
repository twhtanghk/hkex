moment = require 'moment'
hkex = require('../index.coffee')
  lang: 'ch'
  dtStart: moment()

angular
  .module 'starter.controller', ['ionic']

  .run ($templateCache) ->
    $templateCache.put 'templates/item.html',
      """
        {{model.releasedAt}} {{model.code}} {{model.name}}
      """

  .controller 'ListCtrl', ($scope) ->
    hkex
      .then (data) ->
        $scope.hkex = data
