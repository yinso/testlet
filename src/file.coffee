Runner = require './runner'
fs = require 'fs'
path = require 'path'
util = require './util'
require 'coffee-script'


normalizePath = (dirPath, filePath) ->
  #fullPath = dirPath + "/" + filePath # do I want to resolve the fullPath?
  fullPath = path.resolve(path.join(dirPath, filePath))
  path.join(path.dirname(fullPath), path.basename(filePath, path.extname(filePath)))

entry = (dirPath) ->
  runner = new Runner()
  helper = (filePath, next) ->
    loadTest runner, normalizePath(dirPath, filePath), next
  # how do we ensure that this will load coffee-script?
  fs.readdir dirPath, (err, files) ->
    util.forEach files, helper, (err, res) ->
      if err
        console.log "test.fail.load:", err
      else
        console.log 'runner.torun'
        runner.run (err, res) ->
          console.log "result: ", err, res

loadTest = (runner, filePath, next) ->
  try
    util.require filePath, {test: runner}
    next null
  catch e
    next e

module.exports = entry

