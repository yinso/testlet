{deepEqual, forEach} = require './util'
TestResult = require './test-result'
SuiteResult = require './suite-result'
Test = require './test'
Suite = require './suite'

class Runner
  constructor: (@timeout = 2000) ->
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
  it: (name, func) ->
    if not @currentSuite
      throw new Error("test.do must be called within test.add")
    @currentSuite.add new Test(@, name, func)
  ok: (val, msg = "ok(#{val})") ->
    err = new Error(msg)
    if not val
      err.expected = true
      err.actual = val
      throw err
    else if val instanceof Function
      res = val()
      if not res
        err.expected = true
        err.actual = res
        throw err
  equal: (lhs, rhs, msg = "#{lhs} == #{rhs}") ->
    if not deepEqual(lhs, rhs)
      err = new Error(msg)
      err.expected = rhs
      err.actual = lhs
      throw err
  throws: (lhs, msg = "#{lhs} expect to throw") ->
    try
      lhs()
      err = new Error(msg)
      err.expected = "throws"
      err.actual = "no throw"
      throw err
    catch e
      return
  isa: (lhs, rhs, msg = "#{lhs} typeof #{rhs}") ->
    err = new Error(msg)
    err.expected = rhs
    if typeof(rhs) == 'string'
      if not typeof(lhs) == rhs
        err.actual = typeof(lhs)
        throw err
    else
      if not lhs instanceof rhs
        err.actual = false
        throw err
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
