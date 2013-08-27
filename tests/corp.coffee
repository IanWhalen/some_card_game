chai = require 'chai'
chai.should()
mongoose = require 'mongoose'
wipeDbAfterTests = true

{Corp} = require '../server/models/corp'

describe 'Corp', ->

  before (done) ->
    mongoose.connect 'mongodb://localhost/netrunner_test', done

  it 'exists', (done) ->
    Corp.should.be.ok
    done()
  it 'can be instantiated', (done) ->
    corp = new Corp
    corp.should.be.instanceOf Corp
    done()

  after (done) ->
    if ! wipeDbAfterTests
      mongoose.connection.close done
    else
      mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
        mongoose.connection.close done