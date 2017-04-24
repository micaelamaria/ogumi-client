# Copyright (c) 2015 naymspace software (Dennis Nissen)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

angular.module "webClient"
  .service 'ServerService', ($rootScope, Restangular, $document, $q, localStorageService, PhoneService, $http) ->
    @server      = {
      name: null,
      url: null,
      manual: false
    }
    @media       = 'http://localhost:8080'
    @chartimg    = '/'
    @searching   = false

    @init = () =>
      @server = localStorageService.get 'server'
      if navigator.userAgent.match(/Android/i)
        @chartimg = 'file:///android_asset/www/assets/images/'
      else
        @chartimg = window.location.origin + window.location.pathname + 'assets/images/'
      return

    @getMediaUrl = () =>
      @media

    @getChartUrl = () =>
      @chartimg

    @getServerUrl = () =>
      @server.url + "/modelapi"

    @getStompEntryUrl = () =>
      @server.url + "/stomp"

    @getServerFromOgumi = () =>
      deferred = $q.defer()
      Restangular.allUrl('serverlistjson', 'http://ogumi.de/serverlist-1.2.json').withHttpConfig({timeout: 2000}).getList().then(
        (res) ->
          serverlist = []
          for server in res.data
            serverlist.push
              name: server.name
              url: server.url
          deferred.resolve serverlist
        (err) ->
          console.error 'Requesting ogumi.de was unsuccessful.'
          deferred.resolve []
      )
      PhoneService.addResumeCb 'ogumi.de', @getServerFromOgumi
      return deferred.promise

    @searchForServers = () =>
      search = () =>
        deferred = $q.defer()
        if ZeroConf?
          if @searching
            ZeroConf.close()
          @searching = true
          ZeroConf.list '_ogumi-model._tcp.local.',
            1000,
            (obj) ->
              services = []
              for service in obj.service
                if service.urls? and service.urls.length > 0
                  url = service.urls[0]
                  path = service.application
                  services.push
                    name: service.name
                    server: url
                    application: url + '/' +path
              deferred.resolve services
              return
            ,(err) ->
              deferred.reject err
              return
        else
          deferred.resolve []
        return deferred.promise
      PhoneService.addResumeCb 'zeroconf', () ->
        PhoneService.ready().then search
      PhoneService.addPauseCb 'zeroconf', () ->
        PhoneService.ready().then @stopSearching
      return PhoneService.ready().then search

    @stopSearching = () =>
      if ZeroConf?
        if @searching
          ZeroConf.close()
        @searching = false
      return

    @clearSearchingCbs = () ->
      PhoneService.removeResumeCb 'zeroconf'
      PhoneService.removePauseCb 'zeroconf'
      PhoneService.removeResumeCb 'ogumi.de'
      return

    @setServer = (server) =>
      @server = server
      @media  = server
      localStorageService.set("server", @server)
      @setServerIsReachable(@getServerUrl())
      Restangular.setBaseUrl @getServerUrl()
      return

    @getServer = () ->
      @server

    @setServerIsReachable = (url) ->
      $http
        url: url
      .then(
        (response) ->
          $rootScope.serverIsReachable = true
          if (response.data)
            $rootScope.serverInfo = response.data
        ,(error) ->
          $rootScope.serverIsReachable = false
      )

    return
