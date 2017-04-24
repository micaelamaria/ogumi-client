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
  .service 'ModelTranslationService', (ServerService, $http, $q, $translate, $window) ->

    @translations = {}
    @filemapping = {}

    @setFilemapping = (filemapping) =>
      for file in filemapping
        @filemapping[file.name.replace(".json","")] = file
      return

    @init = () ->
      $window.experimentTranslation = (key) ->
        key
      return

    @_load = (lang) =>
      deferred = $q.defer()
      if not @translations[lang]?
        if @filemapping? and @filemapping[lang]?
          file = @filemapping[lang]
          $http.get(file.url).success((data) =>
            @translations[lang] = data
            deferred.resolve 'loaded model translation file'
          ).error () ->
            deferred.reject 'cannot get model translation file'
            return
        else
          deferred.reject 'no filemapping given'
      else
        deferred.resolve 'translation file already loaded'
      return deferred.promise

    @setWindowObject = () =>
      preferred = $translate.use()
      preferredFamily = preferred.split('_')[0]
      fallback  = $translate.fallbackLanguage()
      prom1 = @_load fallback
      prom2 = @_load preferredFamily
      prom3 = @_load preferred
      proms = $q.all [prom1, prom2, prom3]
      translateCb = () =>
        $window.experimentTranslation = (key) =>
          if @translations[preferred]? and @translations[preferred][key]?
            return @translations[preferred][key]
          if @translations[preferredFamily]? and @translations[preferredFamily][key]?
            return @translations[preferredFamily][key]
          if @translations[fallback]? and @translations[fallback][key]?
            return @translations[fallback][key]
          key
        return
      proms.then(translateCb, translateCb)

    return
