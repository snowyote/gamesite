{exec} = require "child_process"

REPORTER = "list"

task "test", "run tests", ->
  exec "NODE_ENV=test
    ./node_modules/.bin/mocha
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script
    --require test/test_helper.coffee
    --colors
    --recursive
  ", (err, output) ->
    console.log output
    throw err if err

compile = (i, o) ->
  exec "./node_modules/.bin/browserify #{i}
   | ./node_modules/.bin/jsmin
    > #{o}
  ",
    (err, output) ->
      throw err if err

task "build", "compile client-side javascript", ->
  compile "client.coffee", "static/client.js"

task "build_test", "compile the testing stub js", ->
  compile "client_test.coffee", "client_test.js"
