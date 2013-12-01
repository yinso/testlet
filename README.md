Testlet - A Simple Test Framework for NodeJS
============================================

Testlet is a simple test framework for Node.

Installation
------------

To install - use npm.

    npm install -g testlet

Usage
-----

Similar with other frameworks, you organize a `test` folder within your source tree, with each files denoting specific
test case. Then you just call testlet at the root of the source tree.

    testlet

In the command line version it will automatically look within the test folder, and then execute them.

Testlet has the following parameters

* `-t|--timeout`

  Default 2000 in milliseconds. This specifies how long a test case is to run before timing out.

  The timeout parameter can also be specified with each test case itself.


Test Script Structure
---------------------

`Testlet` expects similar test script structure to other test framework such as [`Mocha`](http://visionmedia.github.io/mocha/).

You can write a test script as follows

    // foo.js
    describe('this is a test suite', function() {

        it('this is a test case', function() {
            // your assertions go here
        });

        it('this is another test case - an async one', function(done) {
            try {
                // your assertions go here
                done(null);
            } catch (e) {
               done(e);
            }
        });

        it('this test case has a timeout specified', 50000, function(done) {
          // note the second parameter is now a timeout in milliseconds.
          // stuff goes here.
        });
    });

`describe` creates a test suite that can be used to group test cases, and `it` creates a test case that can be used to
run assertions. As long as all assertions pass the test case is successful.

Both `describe` and `it` expects a `name` (string), and a function. The function for `describe` is used to create the
test cases, and the function for `it` is the test case itself.

The function for `it` can be either synchronous or asynchronous. If you define a parameter for the function, it will be
run as async (i.e. you are expected to call the callback). `it` can also take an optional `timeout` parameter to
control timeout for this specific test case. Passing `0` for infinite timeout.

`describe` is an alias for `test.add`, and `it` is an alias for `test.it`.

Assertions
----------

You are free to use any assertion framework. On the other hand, testlet comes with a few built-in assertions for your use.

    test.ok(function() { return true; }, <msg>); // test.ok -> assert the function returns true value

    test.equal(1, 2, <msg>); // test.equal - assert the two values are equal - it's a deepEqual comparison.

    test.throws(function() { throw 1; }, <msg>); // test.throws asserts the function will throw

    test.isa(val, type); // test.isa asserts the value is of the type type. type can be a string (uses typeof) or object (uses instanceof).

Logging
-------

`console.log` is hard to use in combination with test cases because of the asynchronous execution nature. You can
instead log to `test.log` (with the same signature), and the log will be displayed along with the test case result.




