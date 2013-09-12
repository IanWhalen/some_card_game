chai = require 'chai'
mongoose = require 'mongoose'

chai.should()
wipeDbAfterTests = true

# Declare Game schema and compile the Game model
gameSchema = mongoose.Schema
  corp:
    stats:
      score: Number
      credits: Number
      clicks: Number
      handLimit: Number
    remoteServers: Array
  runner:
    stats:
      score: Number
      credits: Number
      clicks: Number
      handLimit: Number
Games = mongoose.model('Games', gameSchema, 'games')


# Export models since they will be otherwise unavailable outside of Meteor
{@Game} = require '../server/models/game' unless Meteor?
global.Game = @Game
{@RemoteServer} = require '../server/models/remoteServer' unless Meteor?
global.RemoteServer = @RemoteServer


global.mongoose = mongoose
global.Games = Games
global.wipeDbAfterTests = wipeDbAfterTests
