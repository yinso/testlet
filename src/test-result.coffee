class TestResult
  constructor: (@case, @logs, @error) ->
    @pass = not @error

module.exports = TestResult
