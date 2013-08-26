# Cakefile

{exec} = require "child_process"

REPORTER = "nyan"

task "test", "run tests", ->
  exec "NODE_ENV=test
    mocha
    ./tests/*.coffee
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script
    --colors
  ", (err, output) ->
    throw err if err
    console.log output
