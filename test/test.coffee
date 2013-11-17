###
runner = require('testlet')

# a single function will
runner.add (test) -> # test by the way is the same as runner...!!!
  test.equal 1, 1
  test.ok (() -> 1 == 1)
  test.not.ok (() -> 1 == 2)
  test.not.equal 1, 2
  test.error () -> throw 1

runner.run (result) ->
###

module.exports =
  (test) ->
    test.equal 1, 1
    test.ok (() -> 1 == 1)
    test.not.ok (() -> 1 == 2)
    test.not.equal 1, 2
    test.throw () -> throw new Error("this is an error")
