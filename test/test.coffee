
module.exports =
  (test) ->
    test.ok (() -> 1 == 1)
    test.not.ok (() -> 1 == 2)
    test.equal 1, 1, 'this is stuff'
    test.not.equal 1, 2
    test.throw () -> throw new Error("this is an error")
    test.not.throw () -> 1
    test.okAsync ((cb) -> cb null, true)
    test.not.okAsync ((cb) -> cb null, null)
    test.equalAsync ((cb) -> cb null, 1), 1
    test.not.equalAsync ((cb) -> cb null, 1), 2
    test.throwAsync ((cb) -> cb new Error("this-is-an-error"))
    test.not.throwAsync ((cb) -> cb null)
    test.isa {foo: 'bar'}, Object
    test.isaAsync ((cb) -> cb null, 1), 'number'
    test.not.isa 'string', 'number'
    test.not.isaAsync ((cb) -> cb null, 'hello'), Object


