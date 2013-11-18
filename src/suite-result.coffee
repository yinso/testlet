TestResult = require './test-result'

class SuiteResult
  constructor: (@suite) ->
    @results = []
    @pass = true
  push: (result) ->
    @results.push result
    if not result.pass
      @pass = false
  count: () ->
    @results.length
  success: () ->
    count = 0
    for i in [0...@results.length]
      if @results[i].pass
        count += 1
    count
  failedResults: () ->
    failed = []
    for i in [0...@results.length]
      if not @results[i].pass
        failed.push @results[i]
    failed

module.exports = SuiteResult
