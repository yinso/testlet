Runner = require './runner'
fs = require 'fs'
path = require 'path'
util = require './util'
CliReporter = require './cli-reporter'
require 'coffee-script'


normalizePath = (dirPath, filePath) ->
  #fullPath = dirPath + "/" + filePath # do I want to resolve the fullPath?
  fullPath = path.resolve(path.join(dirPath, filePath))
  path.join(path.dirname(fullPath), path.basename(filePath, path.extname(filePath)))

entry = (timeout, dirPath) ->
  runner = new Runner(timeout)
  global.test = runner
  global.describe = (args...) ->
    runner.add args...
  global.it = (args...) ->
    runner.it args...
  helper = (filePath, next) ->
    loadTest runner, normalizePath(dirPath, filePath), next
  # how do we ensure that this will load coffee-script?
  fs.readdir dirPath, (err, files) ->
    util.forEach files, helper, (err, res) ->
      if err
        console.error "[Error] encountered error while loading test cases", err
      else
        runner.run (err, res) ->
          if err
            console.error "[Error] encountered error while executing test cases", err
          else
            reporter = new CliReporter res
            reporter.report()

loadTest = (runner, filePath, next) ->
  try
    #util.require filePath, {test: runner}
    require filePath
    next null
  catch e
    next e

module.exports = entry

