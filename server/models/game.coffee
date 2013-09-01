class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value

    @corp = new Corp( @corp, @_id )
    @runner = new Runner( @runner, @_id )


  #-----------------------------------------------------------------------------
  # BOARD FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  newGameSetup: () ->
    [corp, runner] = [new Corp(@corp, @_id), new Runner(@runner, @_id)]

    @logForBothSides 'Starting a new game.'
    corp.startGame()
    runner.startGame()


  createNewRemoteServer: () ->
    count = @['corp']['remoteServers'].length + 1
    newServer =
      name: "Remote Server #{count}"
      ICE: []
      assetsAndAgendas: []
      _id: "remoteServer#{count}"
      actionText: "Install to Remote Server #{count}."

    @_pushToArray 'corp.remoteServers', newServer
    return newServer


  startRun: (targetId) ->
    runner = new Runner( @runner, @_id )

    switch targetId
      when 'corpDeck'
        target =
          name: 'R&D'
      when 'corpHand'
        target =
          name: 'HQ'
      when 'corpDiscard'
        target =
          name: 'Archives'
      else
        server = _.find(@corp.remoteServers, (obj) -> return obj._id is targetId)
        target =
          name: server.name

    if runner.canStartRun( target )
      @_setField 'running', true
    else
      return false


  #-----------------------------------------------------------------------------
  # CARD MOVEMENT FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveCardToResources: (cardObj) ->
    updateHand = {}                                 # {}
    idObj = {}                                      # {}
    idObj['_id'] = cardObj['_id']                   # { _id: 'access-to-globalsec-2' }
    updateHand["runner.hand"] = idObj               # { 'runner.hand' : { _id : 'access-to-globalsec-2' } }

    updateResources = {}                            # {}
    cardObj.loc = 'resources'                       # cardObj
    updateResources["runner.resources"] = cardObj   # { 'runner.resources' : cardObj }

    Games.update @_id,                              # Remove card from Hand
      $pull: updateHand

    Games.update @_id,                              # Add card to installed Resources
      $push: updateResources


  moveTopCardFromDeckToHand: (playerObj, cardObj) ->
    cardObj.loc = 'hand'

    updateDeck = {}
    updateHand = {}

    updateDeck[playerObj.side + ".deck"] = 1
    updateHand[playerObj.side + ".hand"] = cardObj

    Games.update( @._id, { $pop:  updateDeck } )
    Games.update( @._id, { $push: updateHand } )


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  setPlayerClicksToZero: (playerObj) ->
    @setIntegerField playerObj.side + ".stats.clicks", 0


  resetCorpClicks: () ->
    @setIntegerField "corp.stats.clicks", 3


  resetRunnerClicks: () ->
    @setIntegerField "runner.stats.clicks", 4


  #-----------------------------------------------------------------------------
  # LOGGING FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  logForBothSides: (line) ->
    @logForRunner line
    @logForCorp line


  logForRunner: (line) ->
    @addLogLineToSide 'runner', line


  logForCorp: (line) ->
    @addLogLineToSide 'corp', line


  #-----------------------------------------------------------------------------
  #  MISC FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  getNthCardFromDeck: (playerObj, n) ->
    # TODO: handle empty deck
    @[playerObj.side]['deck'].slice(-1*n)[0];


  incTurnCounter: () ->
    @_incIntegerField 'turn', 1


  setCurrentPlayerField: (playerId) ->
    @_setField 'current_player', playerId


  setBooleanField: (targetField, bool) ->
    @_setField targetField, bool


  setIntegerField: (targetField, amount) ->
    @_setField targetField, amount


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  _incIntegerField: (targetField, amount) ->
    modObj = {};
    modObj[targetField] = amount;

    Games.update @._id,
      $inc: modObj


  addLogLineToSide: (side, line) ->
    modObj = {}
    targetField = side + '.logs'
    modObj[targetField] = line

    Games.update @._id,
      $push: modObj


  _setField: (targetField, value) ->
    modObj = {}
    modObj[targetField] = value

    Games.update @._id,
      $set: modObj


  _pushToArray: (targetField, value) ->
    modObj = {}
    modObj[targetField] = value

    Games.update @._id,
      $push: modObj
