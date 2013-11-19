
define(['require','builtin'], function(require) {

// src/util
var ___SRC_UTIL___ = (function(module) {
  (function() {
  var callerFilePath, deepEqual, forEach, path, requireContext, stack;

  path = require('builtin').path;

  deepEqual = function(o1, o2) {
    var both, left;
    left = function(o1, o2) {
      var key, val;
      for (key in o1) {
        val = o1[key];
        if (!o2.hasOwnProperty(key)) {
          return false;
        }
      }
      return true;
    };
    both = function(o1, o2) {
      var key, val;
      for (key in o1) {
        val = o1[key];
        if (!deepEqual(o1[key], o2[key])) {
          return false;
        }
      }
      return true;
    };
    if (o1 === o2) {
      return true;
    } else if (o1 instanceof Object && o2 instanceof Object) {
      return left(o1, o2) && left(o2, o1) && both(o1, o2);
    } else {
      return false;
    }
  };

  forEach = function(ary, iterator, callback) {
    var helper;
    helper = function(i, result) {
      var val;
      if (i === ary.length) {
        return callback(null);
      } else {
        val = ary[i];
        return iterator(val, function(err, result) {
          if (err) {
            return callback(err);
          } else {
            return helper(i + 1, result);
          }
        });
      }
    };
    return helper(0, null);
  };

  stack = function() {
    var err, origPrepStack;
    origPrepStack = Error.prepareStackTrace;
    Error.prepareStackTrace = function(_, stack) {
      return stack;
    };
    err = new Error();
    stack = err.stack;
    Error.prepareStackTrace = origPrepStack;
    return stack;
  };

  callerFilePath = function(beyondFunc) {
    var stacks, top;
    stacks = stack();
    top = stacks[0];
    while (stacks.length > 0) {
      if (stacks[0].getFunctionName() === beyondFunc) {
        stacks.shift();
        return stacks[0].getFileName();
      } else {
        stacks.shift();
      }
    }
    throw new Error("stack_not_matching_funcName: " + beyondFunc);
  };

  requireContext = function(spec, context) {
    var callerPath, key, replaced, val;
    callerPath = callerFilePath('requireContext');
    replaced = {};
    for (key in context) {
      val = context[key];
      if (context.hasOwnProperty(key)) {
        if (global.hasOwnProperty(key)) {
          replaced[key] = global[key];
        }
        global[key] = val;
      }
    }
    return require(path.resolve(callerPath, '..', spec));
  };

  module.exports = {
    deepEqual: deepEqual,
    forEach: forEach,
    require: requireContext,
    stack: stack,
    callerFilePath: callerFilePath
  };

}).call(this);

  return module.exports;
})({exports: {}});
// src/test-result
var ___SRC_TEST_RESULT___ = (function(module) {
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

  return module.exports;
})({exports: {}});
// src/suite-result
var ___SRC_SUITE_RESULT___ = (function(module) {
  (function() {
  var SuiteResult, TestResult;

  TestResult = ___SRC_TEST_RESULT___;

  SuiteResult = (function() {

    function SuiteResult(suite) {
      this.suite = suite;
      this.results = [];
      this.pass = true;
    }

    SuiteResult.prototype.push = function(result) {
      this.results.push(result);
      if (!result.pass) {
        return this.pass = false;
      }
    };

    SuiteResult.prototype.count = function() {
      return this.results.length;
    };

    SuiteResult.prototype.success = function() {
      var count, i, _i, _ref;
      count = 0;
      for (i = _i = 0, _ref = this.results.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (this.results[i].pass) {
          count += 1;
        }
      }
      return count;
    };

    SuiteResult.prototype.failedResults = function() {
      var failed, i, _i, _ref;
      failed = [];
      for (i = _i = 0, _ref = this.results.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (!this.results[i].pass) {
          failed.push(this.results[i]);
        }
      }
      return failed;
    };

    return SuiteResult;

  })();

  module.exports = SuiteResult;

}).call(this);

  return module.exports;
})({exports: {}});
// src/test
var ___SRC_TEST___ = (function(module) {
  (function() {
  var Test, TestResult, timeoutCallback;

  TestResult = ___SRC_TEST_RESULT___;

  timeoutCallback = function(timeout, cb, timeoutCB) {
    var beforeTimeout, obj, whenTimeout;
    obj = {
      id: null,
      timedOut: false,
      once: false
    };
    whenTimeout = function() {
      obj.timedOut = true;
      clearTimeout(obj.id);
      return timeoutCB();
    };
    beforeTimeout = function() {
      if (!obj.timedOut) {
        if (obj.once) {
          return console.error("callback called multipled times", cb);
        } else {
          clearTimeout(obj.id);
          obj.once = true;
          return cb.apply(this, arguments);
        }
      }
    };
    obj.id = setTimeout(whenTimeout, timeout);
    return beforeTimeout;
  };

  Test = (function() {

    function Test(runner, name, func) {
      this.runner = runner;
      this.name = name;
      this.func = func;
      this.async = this.func && this.func.length;
      this.timeout = this.runner.timeout || 2000;
    }

    Test.prototype.run = function(next) {
      var callback, result,
        _this = this;
      callback = timeoutCallback(this.timeout, next, function() {
        return next(null, new TestResult(_this, _this.runner.resetLog(), new Error("timeout " + _this.timeout + " msec exceeded.")));
      });
      if (this.async) {
        try {
          return this.func(function(err, res) {
            var result;
            result = err ? new TestResult(_this, _this.runner.resetLog(), err) : new TestResult(_this, _this.runner.resetLog());
            return callback(null, result);
          });
        } catch (e) {
          return callback(null, new TestResult(this, this.runner.resetLog(), e));
        }
      } else {
        result = (function() {
          try {
            this.func();
            return new TestResult(this, this.runner.resetLog());
          } catch (e) {
            return new TestResult(this, this.runner.resetLog(), e);
          }
        }).call(this);
        return callback(null, result);
      }
    };

    return Test;

  })();

  module.exports = Test;

}).call(this);

  return module.exports;
})({exports: {}});
// src/suite
var ___SRC_SUITE___ = (function(module) {
  (function() {
  var Suite, SuiteResult, Test, TestResult, deepEqual, forEach, _ref;

  _ref = ___SRC_UTIL___, deepEqual = _ref.deepEqual, forEach = _ref.forEach;

  TestResult = ___SRC_TEST_RESULT___;

  SuiteResult = ___SRC_SUITE_RESULT___;

  Test = ___SRC_TEST___;

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

  return module.exports;
})({exports: {}});
// src/runner
var ___SRC_RUNNER___ = (function(module) {
  (function() {
  var Runner, Suite, SuiteResult, Test, TestResult, deepEqual, forEach, _ref,
    __slice = [].slice;

  _ref = ___SRC_UTIL___, deepEqual = _ref.deepEqual, forEach = _ref.forEach;

  TestResult = ___SRC_TEST_RESULT___;

  SuiteResult = ___SRC_SUITE_RESULT___;

  Test = ___SRC_TEST___;

  Suite = ___SRC_SUITE___;

  Runner = (function() {

    function Runner(timeout) {
      this.timeout = timeout != null ? timeout : 2000;
      this.suites = [];
      this.name = "All Tests";
      this.innerLogs = [];
    }

    Runner.prototype.add = function(name, func) {
      var prevSuite, suite;
      suite = new Suite(this, name, func);
      this.suites.push(suite);
      prevSuite = this.currentSuite;
      this.currentSuite = suite;
      try {
        return this.currentSuite["eval"]();
      } finally {
        this.currentSuite = prevSuite;
      }
    };

    Runner.prototype["do"] = function(name, func) {
      if (!this.currentSuite) {
        throw new Error("test.do must be called within test.add");
      }
      return this.currentSuite.add(new Test(this, name, func));
    };

    Runner.prototype.ok = function(val, msg) {
      if (msg == null) {
        msg = "ok(" + val + ")";
      }
      if (!val) {
        throw new Error("failed: " + msg);
      }
    };

    Runner.prototype.equal = function(lhs, rhs, msg) {
      if (msg == null) {
        msg = "" + lhs + " == " + rhs;
      }
      if (!deepEqual(lhs, rhs)) {
        throw new Error("failed: " + msg);
      }
    };

    Runner.prototype.throws = function(lhs, msg) {
      if (msg == null) {
        msg = "" + lhs + " expect to throw";
      }
      try {
        lhs();
        throw new Error("failed: " + msg);
      } catch (e) {

      }
    };

    Runner.prototype.isa = function(lhs, rhs, msg) {
      if (msg == null) {
        msg = "" + lhs + " typeof " + rhs;
      }
      if (typeof rhs === 'string') {
        if (!typeof lhs === rhs) {
          throw new Error("failed: " + msg);
        }
      } else {
        if (!lhs instanceof rhs) {
          throw new Error("failed: " + msg);
        }
      }
    };

    Runner.prototype.run = function(cb) {
      var cases, helper, result;
      result = new SuiteResult(this);
      cases = [].concat(this.suites);
      helper = function(test, next) {
        return test.run(function(err, res) {
          if (err) {
            return next(err);
          } else {
            result.push(res);
            return next(null, result);
          }
        });
      };
      return forEach(cases, helper, function(err, res) {
        return cb(err, result);
      });
    };

    Runner.prototype.log = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.innerLogs.push(args);
    };

    Runner.prototype.resetLog = function() {
      var logs;
      logs = this.innerLogs;
      this.innerLogs = [];
      return logs;
    };

    return Runner;

  })();

  module.exports = Runner;

}).call(this);

  return module.exports;
})({exports: {}});


  return ___SRC_RUNNER___;
});
