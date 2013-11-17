{deepEqual, forEach} = require './util'

class Result
  constructor: (@case, @expected, @actual, @textual) ->
    @pass =
      try
        if (@expected instanceof Function)
          res = @expected @actual
          res
        else
          res = deepEqual @expected, @actual
          res
      catch e
        @error = e
        false

class Test
  @ok: (val) ->
    val and not (val instanceof Error)
  @throws: (val) ->
    val instanceof Error
  @equals: (rhs) ->
    (lhs) ->
      deepEqual(lhs, rhs)
  @negate: (expect) ->
    if expect instanceof Function
      (val) ->
        not expect(val)
    else
      (val) ->
        not deepEqual(val, expect)
  @isa: (type) ->
    if typeof(type) == 'string'
      (val) -> typeof(val) == type
    else
      (val) -> val instanceof type
  constructor: (@proc, @expected, @textual) ->
    if not (@proc instanceof Function)
      proc = @proc
      @proc = () -> proc
  run: (next) ->
    result =
      try
        new Result @, @expected, @proc(), @textual
      catch e
        new Result @, @expected, e, @textual
    next null, result

class AsyncTest extends Test
  constructor: (@proc, @expected, @textual) ->
    if not (@proc instanceof Function)
      proc = @proc
      @proc = (cb) -> cb null, proc
  run: (next) ->
    @proc (err, res) =>
      result =
        if err
          new Result @, @expected, err, @textual
        else
          new Result @, @expected, res, @textual
      next null, result

class NotRunner
  _not: (expect) ->
  constructor: (@prev) ->
  ok: (proc, msg = proc.toString()) ->
    @prev.add new Test proc, Test.negate(Test.ok), {type: 'not.ok', msg: msg}
  okAsync: (proc, msg = proc.toString()) ->
    @prev.add new AsyncTest proc, Test.negate(Test.ok), {type: 'not.ok', msg: msg}
  equal: (lhs, rhs, msg = "#{lhs} != #{rhs}") ->
    @prev.add new Test lhs, Test.negate(rhs), {type: 'not.equal', msg: msg}
  equalAsync: (proc, rhs, msg = "#{proc.toString()} != #{rhs}") ->
    @prev.add new AsyncTest proc, Test.negate(rhs), {type: 'not.equal', msg: msg}
  throw: (proc, msg = proc.toString()) ->
    @prev.add new Test proc, Test.negate(Test.throws), {type: 'not.throw', msg: msg}
  throwAsync: (proc, msg = proc.toString()) ->
    @prev.add new AsyncTest proc, Test.negate(Test.throws), {type: 'not.throw', msg: msg}
  isa: (lhs, type, msg = "#{lhs} is-not-a #{type}") ->
    @prev.add new Test lhs, Test.negate(Test.isa(type)), {type: 'not.isa', msg: msg}
  isaAsync: (lhs, type, msg = "#{lhs} is-not-a #{type}") ->
    @prev.add new AsyncTest lhs, Test.negate(Test.isa(type)), {type: 'not.isa', msg: msg}

class Runner
  constructor: () ->
    @cases = []
    @['not'] = new NotRunner @
  add: (test) ->
    @cases.push test
  ok: (proc, msg = proc.toString()) ->
    @cases.push new Test proc, Test.ok, {type: 'ok', msg: msg}
  okAsync: (proc, msg = proc.toString()) ->
    @cases.push new AsyncTest proc, Test.ok, {type: 'ok', msg: msg}
  equal: (lhs, rhs, msg = "#{lhs} == #{rhs}") ->
    @cases.push new Test lhs, rhs, {type: 'equal', msg: msg}
  equalAsync: (proc, rhs, msg = "#{proc.toString()} == #{rhs}") ->
    @cases.push new AsyncTest proc, rhs, {type: 'equal', msg: msg}
  throw: (proc, msg = proc.toString()) ->
    @cases.push new Test proc, Test.throws, {type: 'throw', msg: msg}
  throwAsync: (proc, msg = proc.toString()) ->
    @cases.push new AsyncTest proc, Test.throws, {type: 'throw', msg: msg}
  isa: (lhs, type, msg = "#{lhs} is-a #{type}") ->
    @cases.push new Test lhs, Test.isa(type), {type: 'isa', msg: msg}
  isaAsync: (lhs, type, msg = "#{lhs} is-a #{type}") ->
    @cases.push new AsyncTest lhs, Test.isa(type), {type: 'isa', msg: msg}
  run: (cb) ->
    results = []
    cases = [].concat(@cases)
    helper = (test, next) ->
      test.run (err, res) ->
        if err
          next err
        else
          results.push res
          next null, results
    forEach cases, helper, (err, res) ->
      cb err, results

module.exports = Runner
