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

describe 'UserCtrl', ->

  scope = null
  $httpBackend = null
  mock = null
  ZeroConf =
    list: (type, time, succcb, errcb) ->
      services =
        service: [
          name: 'Test1'
          application: 'ogumi-model'
          urls: ['http://example.com:8080']
        ]
      succcb(services)
    close: () ->
      return
    unwatch: (type) ->
      return

  beforeEach inject ($rootScope, $injector, $location, Restangular, localStorageService, ServerService) ->
    Restangular.setBaseUrl ''
    $httpBackend = $injector.get('$httpBackend')
    scope = $injector.get('$rootScope')
    window.ZeroConf = ZeroConf
    localStorageService.remove 'ogumi.userid'
    localStorageService.remove 'modelServerUrl'
    $location.path '/login'
    $httpBackend.when('GET', 'app/templates/login.html').respond(200)
    return

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'sets user on login and redirects to sessions', inject ($controller, localStorageService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope

    testUser = {
      username: 'userID',
      access_token: "my_token",
      roles: ['ROLE_USER']
      id: 0
    }
    $httpBackend.expectPOST('/users/login').respond 200, testUser

    $httpBackend.expectGET('app/templates/dashboard.html').respond(200)
    scope.login(testUser)
    $httpBackend.flush()
    expect(scope.user).toBe(testUser)
    expect(localStorageService.get('user')).toEqual(testUser)

  it 'shows an alert if user could not log in', inject ($controller, $rootScope, NotificationService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    spyOn(NotificationService, "flash")
    $httpBackend.expectPOST('/users/login').respond(500)
    scope.login(some: 'user')
    $httpBackend.flush()
    expect(NotificationService.flash).toHaveBeenCalledWith({type: 'danger', head: 'messages.login_failed'})

  it 'redirects to login and shows an alert when registered successfully', inject ($controller, $rootScope) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    $httpBackend.expectPOST('/users/register').respond(200)
    $httpBackend.expectGET('app/templates/login.html').respond(200)
    spyOn($rootScope, "$emit")
    scope.register(some: 'user')
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert',
      type: 'success'
      head: 'Registration successfull'
      info: 'You can now login.<br/><a href="#/login">Go to login</a>'
    )

  it 'shows an alert if user could not register on the server', inject ($controller, $rootScope) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectPOST('/users/register').respond(500)
    scope.register(some: 'user')
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Error!', info: 'Please try again with a different user name.'})

  it 'shows an alert if user has different passwords in registration', inject ($controller, $rootScope) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $httpBackend.expectPOST('/users/register').respond(200)
    $controller 'UserCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    user =
      password: 'p1'
      confirm_password: 'p2'
    scope.register(user)
    $httpBackend.flush()

    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Incorrect input!', info: 'The passwords do not match.'})

  it 'deletes user.id on logout and redirects to login', inject ($controller, localStorageService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    $httpBackend.expectGET('app/templates/login.html').respond(200)
    scope.logout(some: 'user')
    $httpBackend.flush()
    expect(localStorageService.get('userid')).toBeNull()

  it 'shows an alert if user logs out', inject ($controller, $rootScope) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET('app/templates/login.html').respond(200)
    scope.logout(some: 'user')
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'success', head: 'Logged out.'})

  it 'searches for servers when initialized', inject ($controller, $location) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    definedServers = scope.server.length
    $httpBackend.flush()
    expect(scope.server.length).toBe(definedServers+1)

  it 'gets active servers from ogumi.de when initialized', inject ($controller, $location) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [name: 'Hello', url: 'World'])
    $controller 'UserCtrl', $scope: scope
    definedServers = scope.server.length
    $httpBackend.flush()
    expect(scope.server.length).toBe(definedServers+2)
    expect(scope.server).toContain({name: 'Hello', application: 'World'})

  it 'inits currentServer', inject ($controller, $location, localStorageService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    $controller 'UserCtrl', $scope: scope
    $httpBackend.flush()
    expect(scope.currServer.name).toEqual('Test1')
    expect(localStorageService.get('modelServerUrl')).toEqual(scope.currServer)

  it 'doesnt init servers without ZeroConf', inject ($controller, $location) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    window.ZeroConf = null
    $controller 'UserCtrl', $scope: scope
    definedServers = scope.server
    $httpBackend.flush()
    expect(scope.server.length).toBe(definedServers.length)
    expect(scope.currServer).toBe(definedServers[0])

  it 'doesnt overwrite already chosen Serverurl', inject ($controller, $location, localStorageService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    localStorageService.set 'modelServerUrl', 'http://example.com/model-server'
    $controller 'UserCtrl', $scope: scope
    $httpBackend.flush()
    expect(scope.currServer).toBeUndefined()
    expect(scope.serverurl).toBe('http://example.com/model-server')

  it 'doesnt overwrite already chosen Server', inject ($controller, $location, localStorageService) ->
    $httpBackend.when('GET', 'http://ogumi.de/serverlist.json').respond(200, [])
    o =
      name: 'Test'
      server: 'http://example.com:3000'
      application: 'http://example.com:3000/some-path'
    localStorageService.set 'modelServerUrl', JSON.stringify o
    $controller 'UserCtrl', $scope: scope
    $httpBackend.flush()
    expect(scope.currServer.name).toBe('Test')
    expect(scope.currServer.server).toBe('http://example.com:3000')
    expect(scope.currServer.application).toBe('http://example.com:3000/some-path')
    expect(scope.serverurl).toEqual('')
