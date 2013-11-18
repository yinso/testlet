
define(['require','testlet'], function(require) {

// .target/test
var ____TARGET_TEST___ = (function(module) {
  var Runner = require('testlet');
var test = new Runner();
(function() {

  test.add('this is a new suite', function() {
    return test["do"]('this is a test case', function(next) {
      try {
        test.ok((function() {
          return 1 === 1;
        }));
        test.equal(1, 2, '1 should equal 2');
        test.throws(function() {
          throw new Error("this is an error");
        });
        test.isa({
          foo: 'bar'
        }, Object);
        return next();
      } catch (e) {
        return next(e);
      }
    });
  });

}).call(this);

if (window) {
  window.test = test;
}
module.exports = test;
test.run(function (err, res) { console.log(err, res); });
  return module.exports;
})({exports: {}});


  return ____TARGET_TEST___;
});
