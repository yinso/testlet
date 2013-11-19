TestResult = require './test-result'

timeoutCallback = (timeout, cb, timeoutCB) ->
  obj =
    id: null
    timedOut: false
    once: false
  whenTimeout = () ->
    obj.timedOut = true
    clearTimeout obj.id
    timeoutCB()
  beforeTimeout = () ->
    if not obj.timedOut
      if obj.once
        console.error "callback called multipled times", cb
      else
        clearTimeout obj.id
        obj.once = true
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
          result =
            if err
              new TestResult @, @runner.resetLog(), err
            else
              new TestResult @, @runner.resetLog()
          callback null, result
      catch e
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
