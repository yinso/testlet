{deepEqual, forEach} = require './util'
TestResult = require './test-result'
SuiteResult = require './suite-result'
Test = require './test'
Suite = require './suite'

class Runner
  constructor: () ->
    @suites = []
    @name = "All Tests"
    @innerLogs = []
  add: (name, func) -> # if we add inner suite we'll have to be careful about restoring the previous suite.
    # an inner suite - how do add an inner suite?
    suite = new Suite @, name, func
    @suites.push suite
    prevSuite = @currentSuite
    @currentSuite = suite
    try
      @currentSuite.eval()
    finally
      @currentSuite = prevSuite
  do: (name, func) ->
    if not @currentSuite
      throw new Error("test.do must be called within test.add")
    @currentSuite.add new Test(@, name, func)
  ok: (val, msg = "ok(#{val})") ->
    if not val
      throw new Error("failed: #{msg}")
  equal: (lhs, rhs, msg = "#{lhs} == #{rhs}") ->
    if not deepEqual(lhs, rhs)
      throw new Error("failed: #{msg}")
  throws: (lhs, msg = "#{lhs} expect to throw") ->
    try
      lhs()
      throw new Error("failed: #{msg}")
    catch e
      return
  isa: (lhs, rhs, msg = "#{lhs} typeof #{rhs}") ->
    if typeof(rhs) == 'string'
      if not typeof(lhs) == rhs
        throw new Error("failed: #{msg}")
    else
      if not lhs instanceof rhs
        throw new Error("failed: #{msg}")
  run: (cb) ->
    result = new SuiteResult @
    cases = [].concat(@suites)
    helper = (test, next) ->
      test.run (err, res) ->
        if err
          next err
        else
          result.push res
          next null, result
    forEach cases, helper, (err, res) ->
      cb err, result
  log: (args...) ->
    @innerLogs.push args
  resetLog: () ->
    logs = @innerLogs
    @innerLogs = []
    logs

module.exports = Runner
