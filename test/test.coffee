test.add 'this is a new suite', () ->
  test.do 'test', (next) ->
    try
      test.ok (() -> 1 == 1)
      test.equal 1, 2, 'this is stuff'
      test.throws () -> throw new Error("this is an error")
      test.isa {foo: 'bar'}, Object
      next()
    catch e
      next e

