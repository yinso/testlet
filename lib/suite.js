// Generated by CoffeeScript 1.4.0
(function() {
  var Suite, SuiteResult, Test, TestResult, deepEqual, forEach, _ref;

  _ref = require('./util'), deepEqual = _ref.deepEqual, forEach = _ref.forEach;

  TestResult = require('./test-result');

  SuiteResult = require('./suite-result');

  Test = require('./test');

  Suite = (function() {

    function Suite(runner, name, func) {
      this.runner = runner;
      this.name = name;
      this.func = func;
      if (!this.func instanceof Function) {
        throw new Error("Suite_expect_name_and_function; passed: " + this.name + ", " + this.func);
      }
      this.cases = [];
    }

    Suite.prototype["eval"] = function() {
      return this.func();
    };

    Suite.prototype.add = function(testCase) {
      return this.cases.push(testCase);
    };

    Suite.prototype.run = function(next) {
      var cases, helper, result;
      result = new SuiteResult(this);
      helper = function(test, next) {
        return test.run(function(err, res) {
          result.push(res);
          return next();
        });
      };
      cases = [].concat(this.cases);
      return forEach(cases, helper, function(err, res) {
        if (err) {
          return next(err);
        } else {
          return next(null, result);
        }
      });
    };

    return Suite;

  })();

  module.exports = Suite;

}).call(this);
