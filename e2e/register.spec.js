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

describe('Register view', function () {
  var page;

  beforeEach(function () {
    browser.get('http://localhost:3000/#/register');
    page = require('./register.po');
  });

  it('should show error message and disable submit if required fields are not filled out', function() {
    page.username.sendKeys('t');
    page.username.sendKeys(protractor.Key.BACK_SPACE);
    page.password.sendKeys('t');
    page.password2.sendKeys('t');
    page.password.sendKeys(protractor.Key.BACK_SPACE);
    page.password2.sendKeys(protractor.Key.BACK_SPACE);
    page.email.sendKeys('t');
    page.email.sendKeys(protractor.Key.BACK_SPACE);
    page.username.sendKeys('');
    expect(page.username_error.isDisplayed()).toBe(true);
    expect(page.password_error.isDisplayed()).toBe(true);
    expect(page.password2_error.get(0).isDisplayed()).toBe(true);
    expect(page.submit.isEnabled()).toBe(false);
  });

  it('should show error message and disable submit if email isnt an email', function() {
    page.username.sendKeys('test');
    page.password.sendKeys('test');
    page.password2.sendKeys('test');
    page.email.sendKeys('test');
    page.username.sendKeys('');
    expect(page.submit.isEnabled()).toBe(false);
    expect(page.email_error.get(0).isDisplayed()).toBe(true);
  });

  it('should show error message and disable submit if passwords mismatch', function() {
    page.username.sendKeys('test');
    page.password.sendKeys('test');
    page.password2.sendKeys('testtest');
    page.email.sendKeys('test@example.com');
    expect(page.submit.isEnabled()).toBe(false);
    expect(page.password2_error.get(1).isDisplayed()).toBe(true);
  });

  it('should enable submit button if form is valid', function() {
    page.username.sendKeys('test');
    page.password.sendKeys('test');
    page.password2.sendKeys('test');
    page.email.sendKeys('test@example.com');
    expect(page.submit.isEnabled()).toBe(true);
  });
});
