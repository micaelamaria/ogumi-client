angular.module "webClient"
.controller "com.naymspace.ogumi.server.domain.WaitingController", ($scope, $rootScope, $q, $stateParams, $state,
                                $translate, $window, $timeout, $interval, Restangular, localStorageService,
                                NotificationService, ServerService, userService, PhoneService,
                                ModelTranslationService, SocketService, SessionService) ->

  $scope.session = SessionService.session
  $scope.isDone = false

  checkerPromise = null

  @init =  ->
    $scope.waitUntil = moment $scope.session.currentStep.resource.waitUntil, 'YYYY-MM-DD HH:mm:ss'
    checkerPromise = $interval ->
      diff = moment(Date.now()).diff($scope.waitUntil)
      if (diff >= 0)
        $scope.isDone = true

    , 1000

  $scope.$watch "isDone", (val) ->
    $interval.cancel(checkerPromise) if checkerPromise? && val == true

  $scope.onClickNext = ->
    Restangular.one('sessions', $stateParams.id)
    .post 'step/'+$stateParams.step
    .then (res) ->
      $state.go 'root.sessionstep',
        step: res.data.stepIndex
        id: $stateParams.id
      , (res) ->
        console.log("error posting step")
      return

  @init()
