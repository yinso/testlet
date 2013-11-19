TestResult = require './test-result'

timeoutCallback = (timeout, cb, timeoutCB) ->
  obj =
    id: null
    timedOut: false
  whenTimeout = () ->
    obj.timedOut = true
    clearTimeout obj.id
    timeoutCB()
  beforeTimeout = () ->
    if not obj.timedOut
      clearTimeout obj.id
      cb.apply @, arguments
  obj.id = setTimeout whenTimeout, timeout
  beforeTimeout

# if we want to deal with timeout... don't worry about it for now.
class Test
  constructor: (@runner, @name, @func) ->
    @async = @func and @func.length
    @timeout = @runner.timeout or 2000
  run: (next) ->
    callback = timeoutCallback @timeout, next, () =>
      next null, new TestResult @, @runner.resetLog(), new Error("timeout #{@timeout} msec exceeded.")
    if @async
      try
        @func (err, res) =>
          console.log 'Test.async.afterRun', @name
          result =
            if err
              new TestResult @, @runner.resetLog(), err
            else
              new TestResult @, @runner.resetLog()
          callback null, result
      catch e
        console.log 'Test.error', @name
        callback null, new TestResult @, @runner.resetLog(), e
    else
      result =
        try
          @func()
          new TestResult @, @runner.resetLog()
        catch e
          new TestResult @, @runner.resetLog(), e
      callback null, result

module.exports = Test
