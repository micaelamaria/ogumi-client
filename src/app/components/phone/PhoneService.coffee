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
  .service 'PhoneService', ($q, NotificationService) ->

    @deviceready = false
    @isOnline    = true
    @offlineCbs  = []
    @onlineCbs   = []
    @pauseCbs    = []
    @resumeCbs   = []
    @orientCbs   = []

    @init = () =>
      if navigator.userAgent.match(/Android/i)
        document.addEventListener 'deviceready', () =>
          @deviceready = true
          document.addEventListener 'backbutton', (e) ->
            e.preventDefault()
            false
          , false
          document.addEventListener 'offline', () =>
            @_callCbs @offlineCbs
            return
          , false
          document.addEventListener 'online',  () =>
            @_callCbs @onlineCbs
            return
          , false
          document.addEventListener 'pause',   () =>
            @_callCbs @pauseCbs
            return
          , false
          document.addEventListener 'resume',  () =>
            @_callCbs @resumeCbs
            return
          , false
          window.addEventListener 'orientationchange', () =>
            @_callCbs @orientCbs
            return
          , false
          return
        , false
        @addOfflineCb 'notify', @_notifyOffline
        @addOnlineCb  'notify', @_notifyOnline
      else
        @deviceready = true
      return

    @_notifyOffline = () =>
      if @isOnline
        @isOnline = false
        NotificationService.error info: 'messages.offline'
      return

    @_notifyOnline = () =>
      if not @isOnline
        @isOnline = true
        NotificationService.flash info: 'messages.online'
      return

    @_callCbs = (cbs) ->
      for obj in cbs
        for key, fun of obj
          fun()
      return

    @_removeFun = (key, arr) ->
      arr.splice(i, 1) for i, val of arr when Object.keys(val)[0] is key
      return

    @_addFun = (key, fun, arr) ->
      o = {}
      o[key] = fun
      arr.push o
      return

    @addOfflineCb = (key, fun) =>
      @_addFun key, fun, @offlineCbs
      return

    @addOnlineCb = (key, fun) =>
      @_addFun key, fun, @onlineCbs
      return

    @addPauseCb = (key, fun) =>
      @_addFun key, fun, @pauseCbs
      return

    @addResumeCb = (key, fun) =>
      @_addFun key, fun, @resumeCbs
      return

    @addOrientCb = (key, fun) =>
      @_addFun key, fun, @orientCbs
      return

    @removeOfflineCb = (key) =>
      @_removeFun key, @offlineCbs
      return

    @removeOnlineCb = (key) =>
      @_removeFun key, @onlineCbs
      return

    @removePauseCb = (key) =>
      @_removeFun key, @pauseCbs
      return

    @removeResumeCb = (key) =>
      @_removeFun key, @resumeCbs
      return

    @removeOrientCb = (key) =>
      @_removeFun key, @orientCbs
      return

    @ready = () =>
      deferred = $q.defer()
      count = 0
      interval = null
      isReady = false
      isReadyCb = () ->
        if isReady
          deferred.resolve 'Device is ready'
        else
          deferred.reject 'Device isnt ready'
        return
      checkDeviceReady = () =>
        if @deviceready
          if interval?
            clearInterval interval
          isReady = true
          isReadyCb()
        else if count >= 240
          if interval?
            clearInterval interval
          isReadyCb()
        count++
      isReady = checkDeviceReady()
      if not isReady
        interval = setInterval checkDeviceReady, 250
      else
        isReadyCb()
      return deferred.promise

    return
