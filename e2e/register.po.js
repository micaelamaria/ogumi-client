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

var RegisterPage = function() {
  this.username  = element(By.id('username'));
  this.password  = element(By.id('password'));
  this.password2 = element(By.id('password2'));
  this.email     = element(By.id('email'));
  this.submit    = element(By.css('button[type="submit"]'));

  this.username_error  = this.username.element(By.xpath('..')).element(By.css('.text-danger'));
  this.password_error  = this.password.element(By.xpath('..')).element(By.css('.text-danger'));
  this.password2_error = this.password2.element(By.xpath('..')).all(By.css('.text-danger'));
  this.email_error     = this.email.element(By.xpath('..')).all(By.css('.text-danger'));
};

module.exports = new RegisterPage();
