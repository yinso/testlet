TestResult = require './test-result'
SuiteResult = require './suite-result'

class CliReporter
  constructor: (@result) ->
  report: () ->
    if @result instanceof SuiteResult
      @reportSuiteResult @result
    else
      @reportCase @result, 0
  reportSuiteResult: (result, tabLevel = 0) ->
    count = result.count()
    success = result.success()
    failedResults = result.failedResults()
    if result.suite?.name
      @log tabLevel, "Suite:", @escape(result.suite.name)
      @log tabLevel
    @log tabLevel, "status:", (if result.pass then "passed" else "failed"), ". ", success, " / ", count, " passed."
    @log tabLevel
    for failedResult in failedResults
      @reportCase failedResult, tabLevel + 1
  log: (tabLevel, args...) ->
    console.log @tabs(tabLevel), args...
  escape: (str) ->
    '"' + str.replace(/\"/g, "\\\"") + '"'
  tabs: (tabLevel) ->
    Array(tabLevel).join '  '
  reportCase: (testResult, tabLevel = 1) ->
    if testResult instanceof SuiteResult
      @reportSuiteResult testResult, tabLevel
    else
      @log tabLevel, "case: ", @escape testResult.case.name
      @log tabLevel, "func:", testResult.case.func
      @log tabLevel, "error: ", testResult.error
      @log tabLevel

module.exports = CliReporter