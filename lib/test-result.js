// Generated by CoffeeScript 1.4.0
(function() {
  var TestResult;

  TestResult = (function() {

    function TestResult(_case, logs, error) {
      this["case"] = _case;
      this.logs = logs;
      this.error = error;
      this.pass = !this.error;
    }

    return TestResult;

  })();

  module.exports = TestResult;

}).call(this);
