'use strict';

module.exports = function(config) {

  var configuration = {
    autoWatch : false,

    frameworks: ['jasmine'],

    ngHtml2JsPreprocessor: {
      stripPrefix: 'src/',
      moduleName: 'gulpAngular'
    },

    browsers : ['PhantomJS'],

    plugins : [
      'karma-phantomjs-launcher',
      'karma-jasmine',
      'karma-ng-html2js-preprocessor',
      'karma-spec-reporter',
      'karma-coverage'
    ],

    reporters: ['coverage', 'spec'],

    coverageReporter: {
      reporters: [{
        type: 'text-summary'
      }, {
        type: 'cobertura',
        file: 'coverage.xml'
      }, {
        type: 'lcov'
      }]
    },

    preprocessors: {
      '**/*.coffee': ['coffee'],
      'src/**/*.html': ['ng-html2js'],
      '.tmp/serve/app/**/*.js': ['coverage']
    }
  };

  config.set(configuration);
};
