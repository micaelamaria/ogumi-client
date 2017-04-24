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

describe 'SessionStepCtrl', ->

  scope = null
  $httpBackend = null

  session1Step0Url = session1Step0Url

  beforeEach inject ($rootScope, $injector, $location, Restangular, localStorageService, userService, SocketService) ->
    Restangular.setBaseUrl ''
    $httpBackend = $injector.get('$httpBackend')
    scope = $injector.get('$rootScope')
    window.experimentChart =
      parseData: (data) -> return

    userService.setUser {
      id: 0,
      name: 'testuser',
      access_token: 'access!!'
    }

    SocketService.getClient = ->
      connect: ->

    $location.path '/session/1/0'

    $httpBackend.when('GET', 'app/templates/sessionstep.html').respond(200)
    $httpBackend.flush()
    return

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'sets session correctly', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'Test'
    )

    $httpBackend.flush()
    expect(scope.session.id).toBe(1)
    expect(scope.session.money).toBe(0)
    expect(scope.session.step.idx).toBe(0)
    expect(scope.session.step.money).toBe(0)
    expect(scope.session.step.type).toEqual('Test')
    return

  it 'shows an alert on server error', inject ($controller, $rootScope) ->
    $controller 'SessionStepCtrl', $scope: scope
    spyOn($rootScope, "$emit")
    $httpBackend.expectGET(session1Step0Url).respond(500)
    $httpBackend.flush()
    expect($rootScope.$emit).toHaveBeenCalledWith('showAlert', {type: 'danger', head: 'Error!', info: 'An error occured.'})
    return

  it 'sets step to undefined on 204', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(204)
    $httpBackend.flush()
    expect(scope.session.step).toBe(undefined)
    return

  it 'sets step to undefined on no cls', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      amount: 10
    )
    $httpBackend.flush()
    expect(scope.session.step).toBe(undefined)
    return

  it 'sets step and money', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'Test'
      amount: 10
      money: 1
      name: 'Hello Test!'
    )
    $httpBackend.flush()
    expect(scope.session.id).toEqual(1)
    expect(scope.session.step.idx).toEqual(0)
    expect(scope.session.step.type).toBe('Test')
    expect(scope.session.step.name).toEqual('Hello Test!')
    expect(scope.session.money).toEqual(10)
    expect(scope.session.step.money).toEqual(1)
    return

  it 'sets config params for experimentChart on experiment step', inject ($controller, ServerService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      displayFuture: false
      y0max: 100
      y0min: 10
      y1max: 20
      y1min: 5
      xPoints: 110
    )
    $httpBackend.flush()
    expect(window.experimentChart.showFuture).toBeFalsy()
    expect(window.experimentChart.type).toBe('linechart')
    expect(window.experimentChart.y0Max).toBe(100)
    expect(window.experimentChart.y0Min).toBe(10)
    expect(window.experimentChart.y1Max).toBe(20)
    expect(window.experimentChart.y1Min).toBe(5)
    expect(window.experimentChart.paged).toBe(110)
    expect(window.experimentChart.chart).toBeNull()
    expect(window.experimentChart.player).toBe(0)
    expect(window.experimentChart.images).toEqual(ServerService.getChartUrl())
    return

  it 'sets experiment translations on experiment step', inject ($controller, ServerService, $translate) ->
    $controller 'SessionStepCtrl', $scope: scope
    $translate.preferredLanguage('en')

    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      translations:
        en: 'abcde'
    )
    $httpBackend.expectGET(ServerService.getMediaUrl()+'abcde').respond(200,
      hello: 'world'
    )

    $httpBackend.flush()
    expect(window.experimentTranslation('undefinedKey')).toEqual('undefinedKey')
    expect(window.experimentTranslation('hello')).toBe('world')
    return

  it 'inits (not started) experiment step', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      blockStep: true,
      startDate: '2050-01-01 00:00:00'
    )
    $httpBackend.flush()
    expect(scope.session.step.blockStep).toBe(true)
    expect(scope.session.step.loading).toBe(true)
    expect(scope.session.step.stopped).toBeFalsy()
    expect(scope.session.step.disabledSendButton).toBe(true)
    started = scope.session.step.started()
    expect(started).toBeFalsy()
    return

  it 'inits experiment step user input', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      userInput: [
        {
          type: 'double',
          displayAs: 'inputfield'
        }, {
          type: 'Double',
          displayAs: 'range'
        },{
          type: 'int',
          displayAs: 'inputfield'
        }, {
          type: 'Integer',
          displayAs: 'range'
        }
      ]
    )
    $httpBackend.flush()
    expect(scope.session.step.userInput.length).toBe(4)
    expect(scope.session.step.userInput[0].step).toEqual('0.01')
    expect(scope.session.step.userInput[0].type).toEqual('number')
    expect(scope.session.step.userInput[1].step).toEqual('0.01')
    expect(scope.session.step.userInput[1].type).toEqual('range')
    expect(scope.session.step.userInput[2].step).toBe(1)
    expect(scope.session.step.userInput[2].type).toEqual('number')
    expect(scope.session.step.userInput[3].step).toBe(1)
    expect(scope.session.step.userInput[3].type).toEqual('range')
    return

  it 'inits started experiment step', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    spyOn(SocketService, "connect")
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.connect).toHaveBeenCalled()
    return

  it 'inits incentivized task step with no fellow', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
    )
    $httpBackend.flush()
    expect(scope.session.step.num).toBe(0)
    expect(scope.session.step.fellowdone).toBe(true)
    expect(scope.session.step.itdone).toBe(true)
    return

  it 'inits incentivized task step with fellow', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    spyOn(SocketService, "connect")
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      fellow: 'yourfellow'
      uuid: 'abcde'
      fields: ['field']
    )
    $httpBackend.flush()
    expect(scope.session.step.fields.length).toEqual(1)
    expect(scope.session.step.fellow).toEqual('yourfellow')
    expect(scope.session.step.fellowdone).toBeFalsy()
    expect(scope.session.step.itdone).toBeFalsy()
    expect(scope.session.step.uuid).toEqual('abcde')
    expect(SocketService.connect).toHaveBeenCalled()
    return

  it 'inits information step', inject ($controller, ServerService) ->
    $controller 'SessionStepCtrl', $scope: scope
    ServerService.setServer 'http://example.com/ogumi/ogumi-model'
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.InformationStep'
      info: 'Hello Information!'
      fields: [
        {
          type: 'image/jpeg'
          url: 'http://example.com/exampleimage'
        }, {
          type: 'video/mp4'
          url: 'http://example.com/examplevideo'
        }, {
          type: 'application/ogg'
          url: '/ogumi/exampleVideoOgg'
        }, {
          type: 'application/octet-stream'
          url: 'https://example.com/examplevideo'
        }
      ]
    )
    $httpBackend.flush()
    expect(scope.session.step.info).toEqual('Hello Information!')
    expect(scope.session.step.fields.length).toBe(4)
    expect(scope.session.step.fields[0].isVideo).toBeFalsy()
    expect(scope.session.step.fields[0].url)
      .toEqual('http://example.com/exampleimage')
    expect(scope.session.step.fields[1].isVideo).toBe(true)
    expect(scope.session.step.fields[1].url)
      .toEqual('http://example.com/examplevideo')
    expect(scope.session.step.fields[2].isVideo).toBe(true)
    expect(scope.session.step.fields[2].url)
      .toEqual('http://example.com/ogumi/exampleVideoOgg')
    expect(scope.session.step.fields[3].isVideo).toBe(true)
    expect(scope.session.step.fields[3].url)
      .toEqual('https://example.com/examplevideo')
    return

  it 'inits questionnaire step', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Questionnaire'
      fields: ['hello']
    )
    $httpBackend.flush()
    expect(scope.session.step.fields.length).toBe(1)
    return

  it 'increases number of given answers on incentivized task answer', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      fields: ['field1', 'field2', 'field3']
    )
    $httpBackend.flush()
    scope.session.step.num = 1
    scope.addAnswer {}, 'a'
    expect(scope.session.step.num).toBe(2)
    expect(scope.session.step.itdone).toBeFalsy()
    $httpBackend.expectPOST(session1Step0Url).respond(200,
      money: 10.0
      amount: 10.0
    )
    scope.addAnswer {}, 'a'
    scope.nextPage()
    $httpBackend.flush()
    expect(scope.session.step.num).toBe(3)
    expect(scope.session.step.itdone).toBe(true)
    return

  it 'closes websockets when leaving state', inject ($controller, $state, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.whenGET(session1Step0Url).respond(200,
      cls: 'Test'
    )
    $httpBackend.flush()
    spyOn(SocketService, "disconnect")
    $httpBackend.whenGET('/login').respond(200)
    $httpBackend.whenGET('app/templates/login.html').respond(200)
    $state.go 'root.login'
    $httpBackend.flush()
    expect(SocketService.disconnect).toHaveBeenCalled()
    return

  it 'goes to next step', inject ($controller, $state, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'Test'
    )
    $httpBackend.flush()
    spyOn(SocketService, "disconnect")
    spyOn($state, "go")
    scope.nextStep()
    expect($state.go).toHaveBeenCalledWith('root.sessionstep', {id: 1, step:1})
    expect(SocketService.disconnect).toHaveBeenCalled()
    return

  it 'saves data of a step and goes to the next one', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
    )
    $httpBackend.flush()
    spyOn(scope, "nextStep")
    data =
      data: [
        answer: 'hello'
      ]
      user: 0
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
    $httpBackend.expectPOST(session1Step0Url, JSON.stringify(data)).respond(200)
    scope.postStep [answer: 'hello']
    $httpBackend.flush()
    expect(scope.nextStep).toHaveBeenCalled()
    return

  it 'saves data of a step and does not go to the next one if last was incentivizedTask', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
    )
    $httpBackend.flush()
    a =
      onsuc: (prom, res) ->
        prom.resolve res
        return
      onerr: () -> return
    spyOn(a, "onsuc")
    spyOn(scope, "nextStep")
    data =
      data: [
        answer: 'hello'
      ]
      user: 0
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
    $httpBackend.expectPOST(session1Step0Url, JSON.stringify(data)).respond(204)
    scope.postStep [answer: 'hello'], a.onsuc, a.onerr
    $httpBackend.flush()
    expect(a.onsuc).toHaveBeenCalled()
    expect(scope.nextStep.calls.count()).toBe 0
    return

  it 'saves data of a step and stays if incentivized task step and fellow', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    a =
      onsuc: (prom, res) ->
        prom.resolve res
        return
      onerr: () -> return
    spyOn(a, "onsuc")
    spyOn(scope, "nextStep")
    $httpBackend.expectPOST(session1Step0Url).respond(204)
    scope.postStep [answer: 'hello'], a.onsuc, a.onerr
    $httpBackend.flush()
    expect(a.onsuc).toHaveBeenCalled()
    expect(scope.nextStep.calls.count()).toBe(0)
    return

  it 'shows an alert when saving step failed', inject ($controller) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'Test'
    )
    $httpBackend.flush()
    a =
      onsuc: (prom, res) ->
        prom.resolve res
        return
      onerr: () -> return
    spyOn(a, "onerr")
    spyOn(scope, "nextStep")
    $httpBackend.expectPOST(session1Step0Url).respond(500)
    scope.postStep [answer: 'hello'], a.onsuc, a.onerr
    $httpBackend.flush()
    expect(a.onerr).toHaveBeenCalled()
    expect(scope.nextStep.calls.count()).toBe(0)
    return

  ###
  it 'saves user input in an experiment', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    spyOn(SocketService, "sendData")
    scope.saveUserInput [
      value: "1.0"
    ]
    obj =
      action: "post"
      data:
        player: 0
        effort: ["1.0"]
    expect(SocketService.sendData).toHaveBeenCalledWith(JSON.stringify(obj), jasmine.any(Function))
    return
  ###
  # Tests for Websockets

  it 'sets stopped when experiment has stopped', inject ($controller, $timeout,  SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onclose
      code: 1000
      reason: 'Experiment ended'
    $timeout.flush()
    expect(SocketService.socket).toBe(null)
    expect(scope.session.step.stopped).toBe(true)
    return

  it 'sets loading to false on experiment socket connection', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.loading).toBe(true)
    expect(scope.session.step.started()).toBeFalsy()
    SocketService.socket.onopen()
    $timeout.flush()
    expect(scope.session.step.loading).toBe(false)
    return

  it 'sets socket to null on experiment socket close', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.stopped).toBe(false)
    SocketService.socket.onclose
      code: 1006
    expect(SocketService.socket).toBe(null)
    expect(scope.session.step.stopped).toBe(false)
    return

  it 'throws error on experiment socket error', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    try
      SocketService.socket.onerror()
    catch e
      expect(SocketService.socket.onerror).toThrowError(Error)
    return

  it 'does nothing on experiment socket ping', inject ($controller,SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onmessage
      data: '{"ping":"pong"}'
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.startDate).toBe(undefined)
    return

  it 'shows alert on server error on experiment socket', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    spyOn(scope, "$emit")
    SocketService.socket.onmessage
      data: '{"server_error":"Error"}'
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.startDate).toBe(undefined)
    scope.$digest()
    expect(scope.$emit).toHaveBeenCalledWith('showAlert', {
      type: 'danger',
      head: 'Error!',
      info: 'The experiment calculation stopped with an error: Error'
    })
    return

  it 'sets startDate on experiment socket message', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onmessage
      data: '{"start":"2030-01-01 00:01:00"}'
    $timeout.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.startDate.isSame(moment('2030-01-01 00:01:00'))).toBe(true)
    expect(scope.session.step.started()).toBeFalsy()
    expect(scope.session.step.stopped).toBe(false)
    return

  it 'gives data to experimentChart on experiment data', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    spyOn(window.experimentChart, "parseData")
    SocketService.socket.onmessage
      data: '{"model":"data"}'
    $timeout.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(window.experimentChart.parseData).toHaveBeenCalled()
    expect(scope.session.step.disabledSendButton).toBeFalsy()
    return

  it 'closes connection and sets stopped on experiment stop', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.Experiment'
      link: 'http://example.com/ogumi-model/model/abc'
    )
    $httpBackend.flush()
    spyOn(SocketService, "disconnect")
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onmessage
      data: '{"stopped":true}'
    $timeout.flush()
    expect(scope.session.step.stopped).toBe(true)
    expect(SocketService.closeConnection).toHaveBeenCalled()
    return

  it 'sets socket to null on incentivized task socket close', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      uuid: 'abcde'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onclose
      code: 1006
    expect(SocketService.socket).toBe(null)
    return

  it 'throws error on incentivizedTask socket error', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      uuid: 'abcde'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    try
      SocketService.socket.onerror()
    catch e
      expect(SocketService.socket.onerror).toThrowError(Error)
    return

  it 'does nothing on incentivized task socket ping', inject ($controller, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      uuid: 'abcde'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onmessage
      data: '{"ping":"pong"}'
    expect(SocketService.socket).not.toBe(null)
    return

  it 'updates money when fellow is done with incentivized task', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      uuid: 'abcde'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    spyOn(SocketService, "disconnect")
    expect(SocketService.socket).not.toBe(null)
    scope.session.step.itdone = false
    SocketService.socket.onmessage
      data: '{"username":"yourfellow", "user": 1, "fellow_amount": "2.0", "fellow_money": "1.0"}'
    $timeout.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(SocketService.closeConnection.calls.count()).toBe(0)
    expect(scope.session.step.fellowdone).toBe(true)
    expect(scope.session.step.money).toBe("1.0")
    expect(scope.session.money).toBe("2.0")
    scope.session.step.itdone = true
    SocketService.socket.onmessage
      data: '{"username":"yourfellow", "user": 1, "fellow_amount": "2.0", "fellow_money": "1.0"}'
    $timeout.flush()
    expect(SocketService.closeConnection).toHaveBeenCalled()
    expect(scope.session.step.fellowdone).toBe(true)
    expect(scope.session.step.money).toBe("1.0")
    expect(scope.session.money).toBe("2.0")
    return

  it 'updates money when user is done with incentivized task', inject ($controller, $timeout, SocketService) ->
    $controller 'SessionStepCtrl', $scope: scope
    $httpBackend.expectGET(session1Step0Url).respond(200,
      cls: 'com.naymspace.ogumi.server.domain.IncentivizedTask'
      uuid: 'abcde'
      fellow: 'yourfellow'
    )
    $httpBackend.flush()
    expect(SocketService.socket).not.toBe(null)
    SocketService.socket.onmessage
      data: '{"username":"me", "user": 0, "amount": "2.0", "money": "1.0"}'
    $timeout.flush()
    expect(SocketService.socket).not.toBe(null)
    expect(scope.session.step.money).toBe("1.0")
    expect(scope.session.money).toBe("2.0")
    return
