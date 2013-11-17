Runner = require './runner'
fs = require 'fs'
path = require 'path'
{deepEqual, forEach} = require './util'
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
    forEach files, helper, (err, res) ->
      if err
        console.log "fail load:", err
      else
        runner.run (err, res) ->
          console.log "result: ", err, res


loadTest = (runner, filePath, next) ->
  moduleFunc = require filePath
  if not (moduleFunc instanceof Function)
    next new Error("module #{filePath} not export a function")
  else
    try
      moduleFunc(runner)
      next null
    catch e
      next e

module.exports = entry

