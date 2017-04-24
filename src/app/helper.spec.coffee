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

beforeEach module 'webClient', ($provide, $translateProvider, $stateProvider, $injector) ->
  $provide.factory 'customLoader', ($q) ->
    ->
      deferred = $q.defer()
      deferred.resolve {}
      deferred.promise
  $translateProvider.useLoader 'customLoader'
  return

beforeEach inject ($rootScope, $injector, Restangular, localStorageService) ->
  $httpBackend = $injector.get('$httpBackend')
  $httpBackend.when('GET', 'app/layout/header.html').respond(200)
  return
