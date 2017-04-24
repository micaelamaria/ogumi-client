angular.module("webClient").service 'userService', (localStorageService) ->
  @user = {}

  getUser: ->
    @user

  reset: ->
    @setUser {}

  setUser: (value) ->
    @user = value
    localStorageService.set 'user', @user

  _userFromLocalstorage: ->
    @user = localStorageService.get 'user'
