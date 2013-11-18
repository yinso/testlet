{deepEqual, forEach} = require './util'
TestResult = require './test-result'
SuiteResult = require './suite-result'
Test = require './test'

class Suite
  constructor: (@runner, @name, @func) ->
    if not @func instanceof Function
      throw new Error("Suite_expect_name_and_function; passed: #{@name}, #{@func}")
    @cases = []
  eval: () ->
    @func()
  add: (testCase) ->
    @cases.push testCase
  run: (next) ->
    result = new SuiteResult @
    helper = (test, next) ->
      test.run (err, res) ->
        result.push res
        next()
    cases = [].concat(@cases)
    forEach cases, helper, (err, res) ->
      if err
        next err
      else
        next null, result

module.exports = Suite
