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
  .factory 'LogoutFactory', ($rootScope, $state, $translate, localStorageService, SocketService, userService) ->
    logout: () ->
      userService.reset()
      SocketService.disconnect()
      $translate('messages.logged_out').then (text) ->
        $rootScope.$emit 'showAlert',
          type: 'success'
          head: text
        $state.go 'root.login'
      return
