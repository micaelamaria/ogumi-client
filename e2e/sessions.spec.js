/*
 * Copyright (c) 2015 naymspace software (Dennis Nissen)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
describe('Session choose view', function () {
  var page;

  beforeEach(function(){
    browser.get('http://localhost:3000/#/login');
    browser.executeScript("window.localStorage.removeItem('ogumi.userid');");
    browser.executeScript("window.localStorage.setItem('ogumi.userid', '0');");
    browser.get('http://localhost:3000/#/sessions');
    browser.addMockModule('webClientMock', function() {
      angular.module('webClientMock', ['webClient', 'ngMockE2E'])
      .run(['$httpBackend'], function($httpBackend) {
        //FIXME: this is not executed
        $httpBackend.whenGET('/.*\/sessions/i').respond(200, [{
          id: 1,
          name: 'Dummy'
        }, {
          id: 2,
          name: 'Test Session'
        }, {
          id: 3,
          name: 'Secured Session',
          secured: true
        }]);
      });
    },{});
    page = require('./sessions.po');
  });

  afterEach(function(){
    browser.clearMockModules();
  });

  it('should show error message if password was not entered', function() {
    page.select.element(By.cssContainingText('option', 'Secured Session')).click();
    page.password.sendKeys('p');
    page.password.sendKeys(protractor.Key.BACK_SPACE);
    expect(page.password_error.isDisplayed()).toBe(true);
  });

  it('should hide password input if session is not secured', function() {
    page.select.element(By.cssContainingText('option', 'Test Session')).click();
    expect(page.password.isDisplayed()).toBeFalsy();
  });
});
