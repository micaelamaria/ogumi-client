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
  .controller "SessionsCtrl", ($scope, $rootScope, $state, $translate, Restangular, localStorageService, NotificationService) ->

    $scope.sessions = []
    $scope.loading = true

    getSessions = () ->
      Restangular.all('sessions').getList().then(
        (res) ->
          $scope.loading = false
          $scope.sessions = []
          for elem in res.data
            $scope.sessions.push
              id: elem.id
              name: elem.name
              secure: elem.secure
              stompEntry: elem.stompEntry
          if res.data.length > 0
            $scope.soession = $scope.sessions[0]
          return
        (err) ->
          $scope.loading = false
          NotificationService.error()
      )
    getSessions()

    $scope.participate = (session) ->
      $scope.session = session

      if $scope.session.secure
        data.password = $scope.session.password
      Restangular.one('sessions', session.id).post('').then(
        (res) ->
          $scope.step = res.data.step
          $state.go 'root.sessionstep',
            id: session.id
            step: res.data.step
          return
        (err) ->
          if err.status is 403
            NotificationService.error info: 'messages.session_participate_error'
          else if err.status is 410
            NotificationService.error info: 'messages.session_not_active'
          else
            NotificationService.error()
      )
    return
