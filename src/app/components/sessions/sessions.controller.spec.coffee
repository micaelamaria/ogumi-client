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

describe 'SessionsCtrl', ->

  scope = null
  $httpBackend = null
  mock = null

  beforeEach inject ($rootScope, $injector, Restangular, localStorageService, userService) ->
    Restangular.setBaseUrl ''
    $httpBackend = $injector.get('$httpBackend')
    scope = $rootScope.$new()
    userService.setUser {
      id: 0,
      name: 'testuser',
      access_token: 'access!!'
    }
    $httpBackend.when('GET','app/templates/dashboard.html').respond(200)
    $httpBackend.flush()
    return

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'shows an alert on server error', inject ($controller, $rootScope) ->
    $controller 'SessionsCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET('/sessions').respond(500)
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Error!', info: 'An error occured.'})

  it 'is not in loading state after response', inject ($controller) ->
    $controller 'SessionsCtrl', $scope: scope
    $httpBackend.expectGET('/sessions').respond(200)
    $httpBackend.flush()
    expect(scope.loading).toBeFalsy()

  it 'has sessions after response', inject ($controller) ->
    $controller 'SessionsCtrl', $scope: scope
    $httpBackend.expectGET('/sessions').respond(200, [
      id: 1,
      name: "Test"
    ])
    $httpBackend.flush()
    expect(scope.sessions.length).toEqual(1)
    expect(scope.sessions[0].id).toEqual(1)
    expect(scope.sessions[0].name).toEqual("Test")
    expect(scope.sessions[0].secure).toBe(undefined)

  it 'shows an alert on participate server error', inject ($controller, $rootScope) ->
    $controller 'SessionsCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET('/sessions').respond(200)
    $httpBackend.expectPOST('/sessions/1').respond(500)
    scope.participate(
      id: 1
    )
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Error!', info: 'An error occured.'})

  it 'shows an alert when user cannot participate', inject ($controller, $rootScope) ->
    $controller 'SessionsCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET('/sessions').respond(200)
    $httpBackend.expectPOST('/sessions/1').respond(403)
    scope.participate(
      id: 1
    )
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Error!', info: 'Wrong password or session is full.'})

  it 'redirects to session step when user participates', inject ($controller, $rootScope) ->
    $controller 'SessionsCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET('/sessions').respond(200)
    $httpBackend.expectPOST('/sessions/1').respond(200, {step: 0})
    scope.participate(
      id: 1
    )
    $httpBackend.expectGET('app/templates/sessionstep.html').respond(200)
    $httpBackend.flush()
