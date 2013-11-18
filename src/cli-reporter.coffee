TestResult = require './test-result'
SuiteResult = require './suite-result'
util = require 'util'

termColor = (color, text) ->
  start = `'\033'`
  reset = `'\033[0m'`
  colorCode =
    fg:
      black: 30
      red: 31
      green: 32
      yellow: 33
      blue: 34
      magenta: 35
      purple: 35
      cyan: 36
      white: 37
    bg:
      black: 40
      red: 41
      green: 42
      yellow: 43
      blue: 44
      magenta: 45
      cyan: 46
      white: 47
    reset: 0
    bright: 1
    bold: 1
    dim: 2
    underscore: 4
    underline: 4
    blink: 5
    inverse: 6
    hidden: 8

  if typeof(color) == 'string'
    color = {fg: color}

  code = []
  for key, val of color
    if key == 'fg'
      if colorCode.fg.hasOwnProperty(val)
        code.push colorCode.fg[val]
    else if key == 'bg'
      if colorCode.bg.hasOwnProperty(val)
        code.push colorCode.bg[val]
    else if colorCode.hasOwnProperty(key)
      code.push colorCode[key]
  start + '[' + code.join(';') + 'm' + text + reset

escape = (str) ->
  '"' + str.replace(/\"/g, "\\\"") + '"'

tabs = (tabLevel, tab = '  ') ->
  buffer = ''
  for i in [0...tabLevel]
    buffer += tab
  buffer

class CliReporter
  constructor: (@result) ->
  report: () ->
    count = @result.count()
    success = @result.success()
    failedResults = @result.failedResults()
    @log 0, ""
    @log 0, termColor {fg: 'blue', underline: true, bright: true, bold: true}, "Test Results"
    @log 0, ""
    @log 0, "Status:", @status(@result), success, "/", count, "suites passed."
    @log 0, ""
    for failedResult in failedResults
      @reportInner failedResult, 1
  reportInner: (result, tabLevel = 1) ->
    if result instanceof SuiteResult
      @reportSuiteResult result, tabLevel
    else
      @reportCase result, tabLevel
  reportSuiteResult: (result, tabLevel = 0) ->
    count = result.count()
    success = result.success()
    failedResults = result.failedResults()
    if result.suite?.name
      @log tabLevel, "Suite:", termColor({fg: 'blue', underline: true, bright: true, bold: true}, result.suite.name)
      @log tabLevel
    @log tabLevel, "status:", @status(result), success, "/", count, " cases passed."
    @log tabLevel
    for failedResult in failedResults
      @reportCase failedResult, tabLevel + 1
  status: (result) ->
    if result.pass
      termColor {fg: 'green', bright: true, bold: true}, "passed."
    else
      termColor {fg: 'red', bold: true}, "failed."
  log: (tabLevel, args...) ->
    buffer = (arg.toString() for arg in args).join ' '
    lines = buffer.split(/\r\n|\r|\n/)
    for line in lines
      console.log tabs(tabLevel), line
  reportCase: (testResult, tabLevel = 1) ->
    if testResult instanceof SuiteResult
      @reportSuiteResult testResult, tabLevel
    else
      @log tabLevel, "[case]", termColor {fg: 'magenta', underline: true}, testResult.case.name
      @log tabLevel + 1, testResult.case.func
      @log tabLevel, "[actual]", termColor({fg: 'red', bold: true}, testResult.error)
      if testResult.logs.length > 0
        @log tabLevel, "[logs]"
        for log in testResult.logs
          @log tabLevel + 1, log...
      @log tabLevel

module.exports = CliReporter