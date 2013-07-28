class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------  

  setPlayerClicksToZero: (playerObj) ->
    targetField = playerObj['side'] + ".stats.clicks"
    clicks = 0

    @setIntegerField targetField, clicks


  resetCorpClicks: () ->
    @setIntegerField "corp.stats.clicks", 3


  resetRunnerClicks: () ->
    @setIntegerField "runner.stats.clicks", 4


  #-----------------------------------------------------------------------------
  # LOGGING FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  logForBothSides: (line) ->
    @.addLogLineToSide('corp', line);
    @.addLogLineToSide('runner', line);

  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  setCurrentPlayerField: (playerId) ->
    Games.update(@._id, { $set: { current_player : playerId }});


  setIntegerField: (targetField, amount) ->
    modObj = {}
    modObj[targetField] = amount

    Games.update(@._id, { $set: modObj })


  addLogLineToSide: (side, line) ->
    modObj = {}
    targetField = side + '.logs'
    modObj[targetField] = line

    console.log targetField
    console.log line
    Games.update(@._id, { $push: modObj});
