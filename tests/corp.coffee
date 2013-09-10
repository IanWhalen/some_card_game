{Corp} = require '../server/models/corp'

describe 'Corp', ->

  # Before running the full suite of tests, connect to MongoDB
  before (done) ->
    mongoose.connect 'mongodb://localhost/netrunner', done


  # Execute tests
  it 'exists', (done) ->
    Corp.should.be.ok
    done()

  it 'can be instantiated', (done) ->
    corp = new Corp
    corp.should.be.instanceOf Corp
    done()

  it 'can increment credits via add1Credit()', (done) ->
    testGame = new Games
      corp: stats: credits: 5

    testGame.save () ->
      corp = new Corp {}, testGame._id
      do corp.add1Credit
      Games.findOne {_id: testGame._id}, (err, game) ->
        console.log err if err
        credits = game.corp.stats.credits
        credits.should.equal 6
        done()

  it 'can increment credits via useHedgeFund()', (done) ->
    testGame = new Games
      corp: stats: credits: 0

    testGame.save () ->
      corp = new Corp {}, testGame._id
      do corp.useHedgeFund
      Games.findOne {_id: testGame._id}, (err, game) ->
        console.log err if err
        credits = game.corp.stats.credits
        credits.should.equal 9
        done()



  # Cleanup database
  after (done) ->
    if ! wipeDbAfterTests
      mongoose.connection.close done
    else
      mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
        mongoose.connection.close done
