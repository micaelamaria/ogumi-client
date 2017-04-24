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

angular.module 'webClient', [
  'ngAnimate',
  'ngCookies',
  'ngTouch',
  'ngSanitize',
  'ui.router',
  'ui.bootstrap',
  'LocalStorageModule',
  'pascalprecht.translate',
  'restangular'
]
.config ($stateProvider, $urlRouterProvider, RestangularProvider, localStorageServiceProvider) ->

  localStorageServiceProvider.setPrefix 'ogumi'
  localStorageServiceProvider.setNotify true, true

  $stateProvider
    # an abstract state handling auth and resource-loading

    .state 'root',
      abstract: true,
      views:
        header:
          templateUrl: 'app/layout/header.html'
    .state "root.login",
      url: "/login"
      data: public: true
      views:
        'container@':
          controller: "UserCtrl"
          templateUrl: "app/templates/login.html"
    .state "root.register",
      url: "/register"
      data: public: true
      views:
        'container@':
          controller: "UserCtrl"
          templateUrl: "app/templates/register.html"
    .state "root.sessions",
      url: "/"
      views:
        'container@':
          controller: "SessionsCtrl"
          templateUrl: "app/templates/dashboard.html"
    .state "root.sessionstep.with_type",
      url: "/:type"
      views:
        'container@':
          controllerProvider: ($stateParams) ->
            $stateParams.type + "Controller"
          templateUrl: ($stateParams) ->
            "app/components/steps/" + $stateParams.type + "/index.html"
    .state "root.sessionstep",
      url: "/session/:id/:step"
      views:
        'container@':
          controller: "SessionStepCtrl"
          templateUrl: "app/templates/sessionstep.html"


  $urlRouterProvider.otherwise '/'

  RestangularProvider.setFullResponse true
  RestangularProvider.addElementTransformer 'users', true, (user) ->
    user.addRestangularMethod 'login', 'post', 'login'
    user.addRestangularMethod 'register', 'post', 'register'
    user.addRestangularMethod 'status', 'get', 'status'
    return user

.run ($state, $rootScope, localStorageService, ServerService, PhoneService, ModelTranslationService, $translate, userService) ->
  $rootScope.$watch 'lang', (lang) ->
    moment.locale lang
    $translate.use lang
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
    alertScope = angular.element(jQuery('#alerts')).scope()
    alertScope.empty() if alertScope?

    # return if user is authenticated
    return if toState.data?.public || userService.getUser()?.access_token
    # redirect if user  is not authenticated

    e.preventDefault()
    $state.go 'root.login'
  $translate.availableLanguages = ['en', 'de', 'fr']
  ServerService.init()
  PhoneService.init()
  ModelTranslationService.init()
  $rootScope.lang = $translate.use()


.directive 'afterRender', ['$timeout', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.$watch(
      () ->
        scope.$eval attrs.ngBindHtml
      (value) ->
        scope.$eval attrs.afterRender,
          $element: element
        return
    )
    return
]
