{Game} = require '../server/models/game'

describe 'Game', ->

  # Before running the full suite of tests, connect to MongoDB
  before (done) ->
    mongoose.connect 'mongodb://localhost/netrunner', done


  it 'can create the first new Remote Server', (done) ->
    testGame = new Games
      corp: remoteServers: []

    testServer =
      name: "Remote Server 1"
      ICE: []
      assetsAndAgendas: []
      _id: "remoteServer1"
      actionText: "Install to Remote Server 1."

    testGame.save () ->
      game = new Game testGame
      do game.createNewRemoteServer
      Games.findOne {_id: testGame._id}, (err, doc) ->
        console.log err if err
        doc.corp.remoteServers[0].should.deep.equal(testServer)
        done()

  it 'can create a second new Remote Server', (done) ->
    testGame = new Games
      corp: remoteServers: [{}]

    testServer =
      name: "Remote Server 2"
      ICE: []
      assetsAndAgendas: []
      _id: "remoteServer2"
      actionText: "Install to Remote Server 2."

    testGame.save () ->
      game = new Game testGame
      do game.createNewRemoteServer
      Games.findOne {_id: testGame._id}, (err, doc) ->
        console.log err if err
        doc.corp.remoteServers[1].should.deep.equal(testServer)
        done()


  # Cleanup database
  after (done) ->
    if ! wipeDbAfterTests
      mongoose.connection.close done
    else
      mongoose.connection.db.executeDbCommand { dropDatabase:1 }, (err, result) ->
        mongoose.connection.close done
