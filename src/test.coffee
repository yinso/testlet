TestResult = require './test-result'

# if we want to deal with timeout... don't worry about it for now.
class Test
  constructor: (@name, @func) ->
    @async = @func and @func.length
  run: (next) ->
    if @async
      try
        @func (err, res) =>
          result =
            if err
              new TestResult @, err
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

module.exports = Test
