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

describe 'ModelTranslationService', ->

  scope = null
  $httpBackend = null

  beforeEach inject ($rootScope, $injector, $location, localStorageService, ModelTranslationService, userService) ->
    scope = $injector.get('$rootScope')
    $httpBackend = $injector.get('$httpBackend')
    userService.setUser {
      id: 0,
      name: 'testuser',
      access_token: 'access!!'
    }
    $location.path '/session/1/0'
    $httpBackend.when('GET', 'app/templates/sessionstep.html').respond(200)
    window.experimentTranslation = undefined
    ModelTranslationService.setFilemapping
      en: '/en'
      de: '/de'
      de_DE: '/de-DE'
    return

  it 'inititializes model translation function', inject (ModelTranslationService) ->
    expect(window.experimentTranslation).toBeUndefined()
    ModelTranslationService.init()
    expect(typeof window.experimentTranslation).toEqual('function')
    expect(window.experimentTranslation('test')).toBe('test')
    return

  it 'loads translation files', inject (ModelTranslationService, ServerService) ->
    ModelTranslationService._load 'en'
    $httpBackend.expectGET(ServerService.getMediaUrl() + '/en').respond(200,
      hello: 'world'
    )
    $httpBackend.flush()
    expect(ModelTranslationService.translations.en.hello).toBe('world')
    return

  it 'provides translation function regarding language settings', inject (ModelTranslationService, ServerService, $translate) ->
    $translate.use('de_DE')
    $translate.fallbackLanguage('en')
    ModelTranslationService.setWindowObject()
    $httpBackend.expectGET(ServerService.getMediaUrl() + '/en').respond(200,
      hello: 'world1'
      test:  'test1'
      foo:   'bar'
    )
    $httpBackend.expectGET(ServerService.getMediaUrl() + '/de').respond(200,
      hello: 'world2'
      test:  'test2'
    )
    $httpBackend.expectGET(ServerService.getMediaUrl() + '/de-DE').respond(200,
      hello: 'world3'
    )
    $httpBackend.flush()
    expect(window.experimentTranslation('hello')).toBe('world3')
    expect(window.experimentTranslation('test')).toBe('test2')
    expect(window.experimentTranslation('foo')).toBe('bar')
    expect(window.experimentTranslation('baz')).toBe('baz')
    return

  return
