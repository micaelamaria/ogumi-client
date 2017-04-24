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

angular.module("webClient")
  .controller "UserCtrl", (
    $rootScope, $scope, $state, $translate, $q,
    Restangular, localStorageService, NotificationService,
    ServerService, userService, LogoutFactory, SocketService
  ) ->

    $scope.serverSelection = {
      userDefinedServer: {
        url: "",
        name: 'unnamed',
        manual: true
      }
      selectedServer: null
    }

    $scope.user = userService.getUser()
    $scope.server = []
    $scope.currentServer = ServerService.getServer()

    emptyServer = {
      name:"",
      url: ""
    }

    $scope.setServerFromSelection = ->
      if $scope.serverSelection.selectedServer
        ServerService.setServer $scope.serverSelection.selectedServer
      else
        ServerService.setServer emptyServer
    $scope.setServerFromInput = ->
      ServerService.setServer $scope.serverSelection.userDefinedServer

    $scope.$watch 'serverSelection.selectedServer', (val) ->
      ## application <=> url (legacy ogumi server registeres as url as "application"
      ServerService.setServer val if val

    $scope.$watch "serverSelection.userDefinedServer.url", (val) ->
      ServerService.setServer $scope.serverSelection.userDefinedServer if val
      localStorageService.set('lastUserdefinedServerUrl', val)
    , true

    updateList = (serverlists) ->
      for serverlist in serverlists
        for entry in serverlist
          found = false
          for serv in $scope.server
            if serv.application is entry.application
              found = true
              break
          if not found
            $scope.server.push entry
      return

    $scope.init = () ->
      $scope.serverSelection.userDefinedServer.url = localStorageService.get('lastUserdefinedServerUrl')
      prom1 = ServerService.searchForServers()
      prom2 = ServerService.getServerFromOgumi()
      prom = $q.all [prom1,prom2]
      prom.then(updateList,
        (err) ->
          return
      )
      return

    $scope.init()



    $scope.login = (user) ->
      Restangular.all('users').login(user).then(
        (res) ->
          user.username = res.data.username
          user.access_token = res.data.access_token
          user.roles = res.data.roles
          user.password = ''
          userService.setUser(user)
          Restangular.all('users').status().then(
            (res) ->
              userService.getUser().resource = res.data
              $scope.user = userService.getUser()

              ServerService.stopSearching()
              ServerService.clearSearchingCbs()
              SocketService.connect ServerService.getStompEntryUrl(), user.access_token
              $state.go 'root.sessions'
            , (err) ->
              userService.setUser {}
              NotificationService.flash type: 'danger', head: 'messages.login_failed'
          )
          return
        (error) ->
          userService.setUser {}
          NotificationService.flash type: 'danger', head: 'messages.login_failed'
      )

    $scope.register = (user) ->
      if user.password isnt user.confirm_password
        NotificationService.error head: 'messages.password_mismatch_head', info: 'messages.password_mismatch_info'
      user.lang = $translate.use()
      Restangular.all('users').register(user).then(
        (res) ->
          NotificationService.flash
            head: 'messages.register_ok_head'
            info: 'messages.register_ok_info'
            link: 'elements.to_login'
            linkUrl: 'login'
            type: 'success'
          return
        (err) ->
          switch err.data?.reason
            when "DUPLICATE_USERNAME"
              NotificationService.error info: 'messages.register_server_error_duplicate_username'
            when "ERRORS_IN_FIELDS"
              NotificationService.error info: 'messages.register_server_error_server_info'

      )
      return

    $scope.logout = (user) ->
      LogoutFactory.logout()
      return

    return
