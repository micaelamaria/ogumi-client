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
  .controller "SessionStepCtrl", (
    $scope, $rootScope, $q, $stateParams, $state,
    $translate, $window, $timeout, Restangular, localStorageService,
    NotificationService, ServerService, userService, PhoneService, ModelTranslationService, SocketService, SessionService
  ) ->

    $scope.session = SessionService.session

    #$scope.session =
    #  id: parseInt $stateParams.id
    #  stompEntry: $rootScope.stompEntry
    #  money: 0
    #  step:
    #    idx: parseInt $stateParams.step
    #    money: 0
    #    type: null

    $scope.isLandscape = true

    $rootScope.$watch 'lang', (lang) ->
      if $scope.session.currentStep.resource.startDate?
        $scope.session.currentStep.resource.startDate.locale lang
      if $scope.session.currentStep.resource.endDate?
        $scope.session.currentStep.resource.endDate.locale lang
      return



    $scope.$watch 'session.step.gotFirstData', (nv, ov) ->
      if nv and not ov
        triggerResize 1000
      return

    initWaitingStep = (data, userid) ->
      $scope.session.step.stopped = false
      $scope.session.step.loading = true
      if data.id?
        $scope.session.step.id = data.id
        PhoneService.addResumeCb 'waiting', openWaitingSocket
        openWaitingSocket()
      return

    @getSession = () ->
      Restangular.one('sessions', $stateParams.id).one('step', $stateParams.step).get()
      .then(
        (res) ->
          # server will return 204 if there's no content
          # for now this means, we have reached the end of the session
          if res.data.sessionEnd == true
            $scope.session.player = res.data.player
            $scope.sessionEnded = true
            return
          data = res.data
          if not data.currentStep.cls?
            $scope.session.step = undefined
            return

          $scope.session.currentStep.resource = data.currentStep
          $scope.session.player = data.player
          $state.go 'root.sessionstep.with_type',
            type: data.currentStep.cls

          return
        (err) -> NotificationService.error()
      )

      return
    @getSession()

    $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
      PhoneService.removeResumeCb 'experiment'
      PhoneService.removeOrientCb 'experiment'
      PhoneService.removeResumeCb 'waiting'
      PhoneService.removeResumeCb 'incentivizedtask'
      window.experimentChart.chart = null
      return

    PhoneService.addPauseCb 'closeWebsocket', () ->
      SocketService.closeConnection()
      window.experimentChart.chart = null
      return

    $scope.nextStep = () ->
      PhoneService.removeResumeCb 'experiment'
      PhoneService.removeOrientCb 'experiment'
      PhoneService.removeResumeCb 'waiting'
      PhoneService.removeResumeCb 'incentivizedtask'
      window.experimentChart.chart = null
      $state.go 'root.sessionstep',
        id: $scope.session.id
        step: $scope.session.step.idx+1

    $scope.postStep = (step, onsucf, onerrf) ->
      userid = userService.getUser().id
      stepdata = []
      if step?
        for field in step
          if field.answer?
            stepdata.push
              id: field.id
              answer: field.answer
      data =
        data: stepdata
        user: parseInt(userid)
        cls: $scope.session.step.type
      prom = $q.defer()
      onsuc = (res) ->
        if onsucf?
          onsucf prom, res
        else
          prom.resolve res
        return prom.promise
      onerr = (err) ->
        if onerrf?
          onerrf err
        prom.reject err
        return prom.promise
      Restangular.one('sessions', $scope.session.id)
        .post('step/'+$scope.session.step.idx, data)
        .then(onsuc, onerr)
        .then(
          (res) ->
            if $scope.session.step.type isnt 'com.naymspace.ogumi.server.domain.IncentivizedTask'
              $scope.nextStep()
            return
          ,
          (err) ->
            if err.status is 409
              NotificationService.error info: 'messages.already_answered'
              setTimeout ()->
                $scope.nextStep()
              , 5000
            else if err.status is 410
              NotificationService.error info: 'messages.session_not_active'
              setTimeout ()->
                $state.go 'root.sessions'
              , 5000
            else
              NotificationService.error()
        )

    $scope.saveUserInput = (userInput) ->
      vals = (parseFloat ui.value for ui in userInput)
      data =
        input: vals
      SocketService.getClient().send("/app/experiment/update/" + $scope.session.step.userinputlink, {}, JSON.stringify data)



    openWaitingSocket = () ->
      # SocketService.setStompEntryUrl($scope.session.stompEntry)
      # client =  SocketService.connect()
      client.connect {}, ->
        client.subscribe '/topic/waiting', (msg) ->
          $timeout () ->
            $scope.session.step.loading = false

          json = JSON.parse msg.body
          if json.endDate?
            $timeout () ->
              $scope.session.step.endDate = moment json.endDate, 'YYYY-MM-DD HH:mm:ss'

          else if json.stopNow
            $timeout () ->
              $scope.session.step.stopped = true
          return
        , ->
          throw new Error 'Received an error over websocket connection'

  .directive 'initSlider', () ->
    (scope, element, attrs) ->
      scope.$watch "userInputForm", () ->
        if attrs.type is 'range'
          element.rangeslider
            polyfill: false
      return

  .filter 'trusted', ['$sce', ($sce) ->
    (url) ->
      $sce.trustAsResourceUrl url
  ]
