path = require 'path'

deepEqual = (o1, o2) ->
  left = (o1, o2) ->
    for key, val of o1
      if not o2.hasOwnProperty(key)
        return false
    true
  both = (o1, o2) ->
    for key, val of o1
      if not deepEqual(o1[key], o2[key])
        return false
    true
  if o1 == o2 # the same object.
    true
  else if o1 instanceof Object and o2 instanceof Object
    left(o1, o2) and left(o2, o1) and both(o1, o2)
  else
    false

forEach = (ary, iterator, callback) ->
  # we won't do the shift version anymore... we'll pass in an i.
  helper = (i, result) ->
    if i == ary.length
      callback null # no result.
    else
      val = ary[i]
      iterator val, (err, result) ->
        if err
          callback err
        else # don't really care about the previous result? possibly...
          helper i + 1, result
  helper 0, null

stack = () ->
  origPrepStack = Error.prepareStackTrace
  Error.prepareStackTrace = (_, stack) -> stack
  err = new Error()
  stack = err.stack
  Error.prepareStackTrace = origPrepStack
  stack

callerFilePath = (beyondFunc) ->
  stacks = stack()
  top = stacks[0]
  while stacks.length > 0
    if stacks[0].getFunctionName() == beyondFunc
      stacks.shift()
      return stacks[0].getFileName()
    else
      stacks.shift()
  throw new Error("stack_not_matching_funcName: #{beyondFunc}")

requireContext = (spec, context) ->
  callerPath = callerFilePath 'requireContext'
  replaced = {}
  for key, val of context
    if context.hasOwnProperty(key)
      if global.hasOwnProperty(key)
        replaced[key] = global[key]
      global[key] = val
  try
    require path.resolve(callerPath, '..', spec) # .. is required due to the way path works.
  finally
    for key, val of context
      if context.hasOwnProperty(key)
        if replaced.hasOwnProperty(key)
          global[key] = replaced[key]
        else
          delete global[key]

module.exports =
  deepEqual: deepEqual
  forEach: forEach
  require: requireContext
  stack: stack
  callerFilePath: callerFilePath

