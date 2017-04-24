angular.module "webClient"
.controller "com.naymspace.ogumi.server.domain.IncentivizedTaskController", ($scope, $rootScope, $q, $stateParams, $state,
                                $translate, $window, $timeout, Restangular, localStorageService,
                                NotificationService, ServerService, userService, PhoneService,
                                ModelTranslationService, SocketService, SessionService) ->

  $scope.session = SessionService.session
  @stompClient = SocketService.getClient()

  $scope.isDone = false
  $scope.waitForFellow = false

  @init =  ->
    @stompClient.subscribe "/user/topic/incentivizedTask/control/", (message) ->
      message = JSON.parse(message.body)
      $scope.loading = false
      # the server accepted our attendence in this step
      if (message.reason == "SUBSCRIPTION" && message.resultStatus == "SUCCESS")
        console.log("registered for incentivized task ID:" + $scope.session.currentStep.resource.id )

      # server accepted the input, we're now only waiting for fellow to finish
      # Server will send a IS_DONE message to this channel once where're done
      # with this task
      else if (message.reason == "RECEIVEDINPUT" && message.resultStatus == "SUCCESS")
        console.log("Server accepted my answers")
        $scope.waitForFellow = true
        $scope.$apply()

      # Server sent IS_DONE - send post to server
      # indicating that we're done with this step
      else if (message.reason == "IS_DONE")
        updateStepInfo().then ->
          $scope.isDone = true
        @stompClient.unsubscribe "/user/topic/incentivizedTask/control/"

    # Subscribe incentivized task
    @stompClient.send("/app/incentivizedTask/subscribe/" + $scope.session.currentStep.resource.id, {})

    if $scope.session.currentStep.resource.randomized?
      $scope.session.currentStep.resource.fields = shuffleArray $scope.session.currentStep.resource.fields
      $scope.showfun = (index) ->
        return index is $scope.session.currentStep.num
      $scope.pagefun = () ->
        curr  = $scope.session.currentStep.num + 1
        total = $scope.session.currentStep.resource.fields.length
        return curr + '/' + total
      $scope.isBeforeNextPage = () ->
        return true
    else
      $scope.showfun = (index) ->
        return Math.floor(index/5) is Math.floor($scope.session.currentStep.num/5)
      $scope.pagefun = () ->
        curr  = Math.floor($scope.session.currentStep.num/5)+1
        total =Math.ceil($scope.session.currentStep.resource.fields.length/5)
        return curr + '/' + total
      $scope.isBeforeNextPage = () ->
        isBeforeEnd = $scope.session.currentStep.num is $scope.session.currentStep.resource.fields.length - 1
        return $scope.session.currentStep.num % 5 is 4 or isBeforeEnd
    $scope.session.currentStep.num = 0
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

  shuffleArray = (arr) ->
    m = arr.length
    while (m > 0)
      i = Math.floor(Math.random() * m--)
      t = arr[m]
      arr[m] = arr[i]
      arr[i] = t
    arr

  $scope.nextPage = () ->
    $scope.session.currentStep.num++
    if $scope.session.currentStep.num >= $scope.session.currentStep.resource.fields.length
      SocketService.getClient().send("/app/incentivizedTask/update/" +
        $scope.session.currentStep.resource.id, {}, JSON.stringify $scope.session.currentStep.resource.fields)
    return

  $scope.addAnswer = (field, chosen) ->
    isclean = false
    if not field.answer?
      isclean = true
    field.answer = chosen
    if isclean and not $scope.isBeforeNextPage()
      $scope.session.currentStep.num++
    return

  $scope.nextStep = ->
    Restangular.one('sessions', $stateParams.id)
    .post('step/'+$stateParams.step, {})
    .then(
      (res) ->
        $state.go 'root.sessionstep',
          step: res.data.stepIndex
          id: $stateParams.id
        return
    ,
      (res) ->
        console.log "error in incentivized task"
    )

  @init()
