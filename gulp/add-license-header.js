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

var gulp    = require('gulp');
var fs      = require('fs');

var $ = require('gulp-load-plugins')({
  pattern: ['gulp-*']
});

module.exports = function(options) {

  var lic = require('../licenseheader.json');

  gulp.task('js-gulp-header', function () {
    return gulp.src([
      "gulp/add-license-header.js",
      "gulp/package-app.js",
      "gulp/tomcat-deploy.js"
      ])
      .pipe($.header(fs.readFileSync('licenseheader-stars.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('gulp/'));
  });

  gulp.task('js-e2e-header', function () {
    return gulp.src("e2e/**/*.js")
      .pipe($.header(fs.readFileSync('licenseheader-stars.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('e2e/'));
  });

  gulp.task('coffee-sh-header', function () {
    return gulp.src("update-zeroconf.sh")
      .pipe($.replace("#!/bin/bash\n\n", ""))
      .pipe($.header(fs.readFileSync('licenseheader-hash.txt', 'utf8'), { lic : lic } ))
      .pipe($.header("#!/bin/bash\n\n"))
      .pipe(gulp.dest('./'));
  });

  gulp.task('js-src-header', function () {
    return gulp.src("src/app/lib/experimentChart.js",  {base: './src'})
      .pipe($.header(fs.readFileSync('licenseheader-stars.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('src/'));
  });

  gulp.task('coffee-src-header', function () {
    return gulp.src("src/**/*.coffee",  {base: './src'})
      .pipe($.header(fs.readFileSync('licenseheader-hash.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('src/'));
  });

  gulp.task('scss-src-header', function () {
    return gulp.src("src/**/*.scss",  {base: './src'})
      .pipe($.header(fs.readFileSync('licenseheader-stars.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('src/'));
  });

  gulp.task('html-src-header', function () {
    return gulp.src("src/**/*.html",  {base: './src'})
      .pipe($.header(fs.readFileSync('licenseheader-xml.txt', 'utf8'), { lic : lic } ))
      .pipe(gulp.dest('src/'));
  });

  gulp.task('add-license-header', [
    'js-gulp-header',
    'js-e2e-header',
    'coffee-sh-header',
    'coffee-src-header',
    'scss-src-header'
  ]);

};
