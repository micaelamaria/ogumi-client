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
  .controller "AlertCtrl",($scope, $rootScope, $window) ->

    $scope.alerts = []

    $scope.addAlert = (obj) ->
      $scope.alerts.push obj

    $scope.closeAlert = (index) ->
      $scope.alerts.splice index, 1

    $scope.empty = () ->
      $scope.alerts = []

    $rootScope.$on 'showAlert', (ev, obj) ->
      ev.preventDefault()
      ev.stopPropagation()
      $scope.addAlert obj
      $window.scrollTo 0, 0
      return false

    return
