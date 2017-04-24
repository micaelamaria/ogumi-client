angular.module("webClient")
.factory 'authenticationHttpInterceptor',  ($rootScope, $injector, $q, localStorageService) ->

  request: (config) ->
    # set x-auth-token header if url starts with url of selected server
    if ($injector.get('userService')?.getUser()?.access_token)
      config.headers['Authorization'] =
        ("Bearer " + $injector.get('userService').getUser()?.access_token) if config.url.indexOf($injector.get('ServerService').getServerUrl()) == 0
    config
  response: (response) ->
    # redirect to login page if response status is 401
    if response.status == 401
      $rootScope.$emit 'showAlert',
        type: 'danger'
        head: 'messages.login_failed' # TODO: set correct Message
      $injector.get('$state').go 'root.login'
    response

.config ($httpProvider) ->
  $httpProvider.interceptors.push('authenticationHttpInterceptor')
