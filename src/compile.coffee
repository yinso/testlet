amdee = require 'amdee'
fs = require 'fs'
path = require 'path'
util = require './util'
coffee = require 'coffee-script'

# we'll resolve all the file in sync fashion.
resolveFiles = (filePath) ->
  helper = (filePath, files) ->
    try
      stat = fs.statSync filePath
      if stat.isDirectory()
        filePaths = fs.readdirSync(filePath)
        for file in filePaths
          helper path.join(filePath, file), files
      else
        data = fs.readFileSync filePath, 'utf8'
        data =
          if path.extname(filePath) == '.coffee'
            coffee.compile(data)
          else
            data
        files.push(data)
        files
    catch e # file not exist...
      files
  files = []
  files = helper filePath, []
  files

# copying all of the files over would be hard.
template = (timeout, files, targetPath) ->
  """
var Runner = require("testlet");
var test = new Runner(#{timeout});
function describe () {
  test.add.apply(test, arguments);
}

function it () {
  test.it.apply(test, arguments);
}

#{files.join('')}
if (window) {
  window.test = test;
}
module.exports = test;
test.run(function (err, res) { console.log(err, res); });
"""

compile = (timeout, dirPath, targetPath, cb) ->
  # we should first create a temporary directory...

  # do we want to use the files to rewrite things toward the appropriate
  files = resolveFiles path.resolve(dirPath)
  fs.writeFile targetPath, template(timeout, files, path.resolve(targetPath)), 'utf8', (err) ->
    if err
      cb err
    else
      # let's also copy the main.js over... hmm...
      # let's start the amdee...
      amdee.run {source: targetPath, target: path.join(path.dirname(targetPath), "main.js"), recursive: true}
      cb()

module.exports = compile
