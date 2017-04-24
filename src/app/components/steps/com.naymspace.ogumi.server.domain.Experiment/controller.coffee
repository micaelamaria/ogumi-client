angular.module "webClient"
.controller "com.naymspace.ogumi.server.domain.ExperimentController", ($scope, $rootScope, $q, $stateParams, $state,
                                $translate, $window, $timeout, Restangular, localStorageService,
                                NotificationService, ServerService, userService, PhoneService,
                                ModelTranslationService, SocketService, SessionService) ->

  $scope.session = SessionService.session
  $scope.cumulatedValues = {}

  stompClient = SocketService.getClient()

  $scope.experimentStatus = "LOADING"

  init =  ->
    $scope.loading = true
    ModelTranslationService.setFilemapping $scope.session.currentStep.resource.translations

    $scope.session.currentStep.resource.startDate = moment $scope.session.currentStep.resource.start, 'YYYY-MM-DD HH:mm:ss'
    prom = ModelTranslationService.setWindowObject()

    cb = () ->
      $scope.experimentTranslation = window.experimentTranslation
    prom = prom.then cb, cb
    window.experimentChart.chart  = null
    window.experimentChart.showFuture = !!$scope.session.currentStep.resource.displayFuture
    window.experimentChart.type   = $scope.session.currentStep.resource.diagram || 'linechart'
    window.experimentChart.y0Max   = parseFloat($scope.session.currentStep.resource.y0max) || null
    window.experimentChart.y0Min   = parseFloat($scope.session.currentStep.resource.y0min) || 0
    window.experimentChart.y1Max   = parseFloat($scope.session.currentStep.resource.y1max) || null
    window.experimentChart.y1Min   = parseFloat($scope.session.currentStep.resource.y1min) || 0
    window.experimentChart.paged  = parseFloat($scope.session.currentStep.resource.xPointsVisible) || null
    window.experimentChart.stepsize = parseInt($scope.session.currentStep.resource.tStep) || 1
    window.experimentChart.player = parseInt($scope.session.player.id)
    window.experimentChart.images = ServerService.getChartUrl()

    $scope.playerId = parseInt($scope.session.player.id)
    $scope.experimentStatus = $scope.session.currentStep.resource.status.name

    $scope.disabledSendButton = true
    $scope.blockStep = $scope.session.currentStep.resource.blockStep if $scope.session.currentStep.resource.blockStep?

    if $scope.session.currentStep.resource.link?
      link = $scope.session.currentStep.resource.link
      $scope.session.currentStep.resource.userinputlink = link
      PhoneService.addResumeCb 'experiment', () ->
        window.experimentChart.chart  = null
        openExperimentWebsocket()
        return
      establishExperimentConnection(link)

    detectOrientation()
    triggerResize(1000)
    PhoneService.addOrientCb 'experiment', () ->
      detectOrientation()
      triggerResize(2000)
      return

    $scope.active = () ->
      $scope.experimentStatus == "ACTIVE"


    prom.then () ->
      initExperimentUserInput($scope.session.currentStep.resource.userInput) if $scope.session.currentStep.resource.userInput?
      return
    return


  updateStepInfo = ->
    $q (resolve, reject) ->
      Restangular.one('sessions', $stateParams.id).one('step', $stateParams.step).get()
      .then(
        (res) ->
          $scope.profit = res.data.stepProfit
          $scope.session.player.money = res.data.player.money
          resolve()
      , (error) ->
        reject()
      )


  establishExperimentConnection = (experimentUUID) ->
    # Experiment Control Channel (EXPERIMENT_ENDED, EXPERIMENT_ERROR)
    stompClient.subscribe "/user/topic/experiment/control/" + experimentUUID, (message) ->
      message = JSON.parse(message.body)

      if (message.reason == "EXPERIMENT_ENDED")
        $timeout () ->
          updateStepInfo().then ->
            $scope.experimentStatus = "ENDED"
            window.experimentChart.chart = null

          stompClient.unsubscribe "/user/topic/experiment/control/" + experimentUUID
          stompClient.unsubscribe "/user/queue/experiment/updates/" + experimentUUID

      else if (message.reason == "EXPERIMENT_ERROR")
        $scope.experimentStatus = "ENDED"
        NotificationService.error
          info: 'messages.experiment_error'
          additionalInfo: json.server_error
        $scope.$apply()
        stompClient.unsubscribe "/user/topic/experiment/control/" + experimentUUID

    # Experiment updated
    stompClient.subscribe "/user/queue/experiment/updates/" + experimentUUID, (message) ->
      $scope.experimentStatus = "ACTIVE"
      $scope.$apply()
      json = JSON.parse(message.body)

      if json.ping?
        return

      if json.server_error?
        NotificationService.error
          info: 'messages.experiment_error'
          additionalInfo: json.server_error
        return

      if json.model?
        newData = []
        # reformat model data to fit to legacy code
        for i in [0..json.model.data.time.length]
          curStep = {}
          for label, values of json.model.data
            curStep[label] = values[i]
          newData.push(curStep)
        json.model.data = newData
        #########################################
        $timeout () ->
          $scope.disabledSendButton = false
          $scope.gotFirstData       = true
          if json.model.cumulatedData?
            $scope.cumulatedValues = json.model.cumulatedData
            $scope.$apply()
          window.experimentChart.parseData json
    , ->
      throw new Error 'Received an error over websocket connection'

  detectOrientation = () ->
    if window.screen?
      # we cannot use window.orientation here since
      # the reference tablets landscape mode is normal portrait mode
      $timeout () ->
        $scope.isLandscape = window.screen.width >= window.screen.height
        return
    return

  triggerResize = (time) ->
    # Fire resizing event, esp. for the experiment graph and the slider
    setTimeout () ->
      window.dispatchEvent(new Event('resize'))
      return
    , time
    return

  initExperimentUserInput = (data) ->
    $scope.userInput = []
    for ui in $scope.session.currentStep.resource.userInput
      $scope.userInput.push _.extend ui,
        if ui.type in ['int', 'Integer']
          step: 1
          type: if ui.displayAs is 'inputfield' then 'number' else 'range'
          value: ui.default
        else
          step: '0.01'
          type: if ui.displayAs is 'inputfield' then 'number' else 'range'
          value: ui.default
    return

  $scope.onClickNext = ->
    Restangular.one('sessions', $stateParams.id)
    .post 'step/'+$stateParams.step
    .then (res) ->
      $state.go 'root.sessionstep',
        step: parseInt($stateParams.step) + 1
        id: $stateParams.id
    , (res) ->
      console.log("error posting step")
      return


  $scope.sendUserInput = (userInput) ->
    vals = (parseFloat ui.value for ui in userInput)
    data =
      input: vals
    stompClient.send("/app/experiment/update/" + $scope.session.currentStep.resource.userinputlink, {}, JSON.stringify data)

  init()
