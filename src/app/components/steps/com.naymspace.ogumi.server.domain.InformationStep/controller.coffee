angular.module "webClient"
.controller "com.naymspace.ogumi.server.domain.InformationStepController", ($scope, $rootScope, $q, $stateParams, $state,
                                $translate, $window, $timeout, Restangular, localStorageService,
                                NotificationService, ServerService, userService, PhoneService,
                                ModelTranslationService, SocketService, SessionService) ->

  $scope.session = SessionService.session

  @init =  ->
    $scope.fields = []
    if $scope.session.currentStep.resource.fields?
      for field in $scope.session.currentStep.resource.fields
        obj = angular.copy field
        obj.isVideo = field.type.indexOf('video/') >= 0 or field.type is 'application/ogg' or field.type is 'application/octet-stream'
        if field.url.indexOf('http://') < 0 and field.url.indexOf('https://') < 0
          obj.url = ServerService.getMediaUrl()+field.url
        $scope.fields.push obj
    return
  @init()

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
