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
  runner:
    stats:
      score: Number
      credits: Number
      clicks: Number
      handLimit: Number
Games = mongoose.model('Games', gameSchema, 'games')


# Export everything necessary to the global namespace
global.mongoose = mongoose
global.Games = Games
global.wipeDbAfterTests = wipeDbAfterTests
