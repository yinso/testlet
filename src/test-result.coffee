class TestResult
  constructor: (@case, @error) ->
    @pass = not @error

module.exports = TestResult
