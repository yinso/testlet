TestResult = require './test-result'

# if we want to deal with timeout... don't worry about it for now.
class Test
  constructor: (@runner, @name, @func) ->
    @async = @func and @func.length
  run: (next) ->
    if @async
      try
        @func (err, res) =>
          result =
            if err
              new TestResult @, @runner.resetLog(), err
            else
              new TestResult @, @runner.resetLog()
          next null, result
      catch e
        next null, new TestResult @, @runner.resetLog(), e
    else
      result =
        try
          @func()
          new TestResult @, @runner.resetLog()
        catch e
          new TestResult @, @runner.resetLog(), e
      next null, result

module.exports = Test
