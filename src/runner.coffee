{deepEqual, forEach} = require './util'

class TestResult
  constructor: (@case, @error) ->
    @pass = not @error

# if we want to deal with timeout... don't worry about it for now.
class Test
  constructor: (@name, @func) ->
    @async = @func and @func.length
  run: (next) ->
    if @async
      try
        @func (err, res) =>
          console.log 'Test.run', @async, @func
          result =
            if err
              new TestResult @, e
            else
              new TestResult @
          next null, result
      catch e
        next null, new TestResult @, e
    else
      result =
        try
          @func()
          new Result @
        catch e
          new Result @, e
      next null, result

class SuiteResult
  constructor: (@suite) ->
    @results = []
    @pass = true
  push: (result) ->
    @results.push result
    if not result.pass
      @pass = false

class Suite
  constructor: (@name, @func) ->
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

class Runner
  constructor: () ->
    @suites = []
  add: (name, func) -> # if we add inner suite we'll have to be careful about restoring the previous suite.
    # an inner suite - how do add an inner suite?
    suite = new Suite(name, func)
    @suites.push suite
    prevSuite = @currentSuite
    @currentSuite = suite
    try
      @currentSuite.eval()
    finally
      @currentSuite = prevSuite
  do: (name, func) ->
    @currentSuite.add new Test(name, func)
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
    console.log 'Runner.run'
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

module.exports = Runner
