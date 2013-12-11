TestResult = require './test-result'

timeoutCallback = (timeout, cb, timeoutCB) ->
  maxTimeout = 2147483648
  timeout = if timeout == 0 then Infinity else timeout
  obj =
    id: null
    timedOut: false
    once: false
    remainder: timeout
  largeTimeout = (cb, timeout) ->
    decr = () ->
      if obj.remainder < maxTimeout
        res = obj.remainder
        obj.remainder = 0
        res
      else
        res = maxTimeout
        obj.remainder -= maxTimeout
        res
    callback = () ->
      if obj.remainder > 0
        clearTimeout obj.id
        time = decr()
        obj.id = setTimeout callback, time
        obj.id
      else
        clearTimeout obj.id
        cb()
    callback()
  whenTimeout = () ->
    obj.timedOut = true
    clearTimeout obj.id
    timeoutCB()
  beforeTimeout = () ->
    if not obj.timedOut
      if obj.once
        return
      else
        clearTimeout obj.id
        obj.once = true
        cb.apply @, arguments
  obj.id = largeTimeout whenTimeout, timeout
  beforeTimeout

# if we want to deal with timeout... don't worry about it for now.
class Test
  constructor: (@runner, @name, @func, @timeout = @runner.timeout or 2000) ->
    @async = @func and @func.length
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
