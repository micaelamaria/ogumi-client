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
  .controller "NavCtrl", (
    $scope, $rootScope, localStorageService, $window,
    $translate, $timeout, $modal, LogoutFactory, PhoneService,
    userService, ServerService
  ) ->

    $scope.isUserLoggedIn = () -> userService.getUser()?
    $scope.logout = () -> LogoutFactory.logout()
    $scope.reload = () -> $window.location.reload()

    $scope.availableLanguages = $translate.availableLanguages

    $scope.switchLang = (lang) ->
      $rootScope.lang = lang

    $scope.username = () ->
      userService.getUser()?.resource.username

    $scope.server = () ->
      ServerService.getServerUrl()
    $scope.version = () ->
      return ''

    PhoneService.ready().then () ->
      if cordova?.getAppVersion?
        cordova.getAppVersion.getVersionNumber().then (version) ->
          $timeout () ->
            $scope.version = () ->
              return version

    $scope.open = (size) ->
      modalInstance = $modal.open
        templateUrl: 'infoModal.html',
        controller: 'InfoModalCtrl'
        size: size
        resolve:
          username: $scope.username
          server: $scope.server
          version: $scope.version
    return

.controller 'InfoModalCtrl', ($scope, $modalInstance, username, server, version) ->

  $scope.username = username
  $scope.server = server
  $scope.version = version

  $scope.isCollapsed = true

  $scope.cancel = () ->
    $modalInstance.dismiss 'cancel'

  return
