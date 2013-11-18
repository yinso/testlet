describe 'this is a new suite', () ->
  it 'this is a test case', (next) -> # closure failed? hmm... that makes no sense.
    try
      test.log "ok", "1 == 1"
      test.ok (() -> 1 == 1)
      test.log "equal", "1 == 2"
      test.equal 1, 1
      test.log "throws"
      test.throws () -> throw new Error("this is an error")
      test.log "isa"
      test.isa {foo: 'bar'}, Object
      next()
    catch e
      next e

