angular.module "webClient"
.controller "com.naymspace.ogumi.server.domain.QuestionnaireController", ($scope, $rootScope, $q, $stateParams, $state,
                                $translate, $window, $timeout, Restangular, localStorageService,
                                NotificationService, ServerService, userService, PhoneService,
                                ModelTranslationService, SocketService, SessionService) ->

  $scope.session = SessionService.session

  @init =  ->
    $scope.fields = []
    if $scope.session.currentStep.resource.fields?
      $scope.fields = $scope.session.currentStep.resource.fields
    return
  @init()

  $scope.onClickNext = ->
    Restangular.one('sessions', $stateParams.id)
    .post 'step/'+$stateParams.step, data
    .then (res) ->
      $state.go 'root.sessionstep',
        step: parseInt($stateParams.step) + 1
        id: $stateParams.id
      , (res) ->
        console.log("error posting step")
      return


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
      cls: $scope.session.currentStep.resource.cls

    Restangular.one('sessions', $stateParams.id)
    .post('step/'+$stateParams.step, data)
    .then (res) ->
      $state.go 'root.sessionstep',
        step: parseInt($stateParams.step) + 1
        id: $stateParams.id
      , (res) ->
        console.log("error posting step")
      return
