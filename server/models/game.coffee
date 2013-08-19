class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  #-----------------------------------------------------------------------------
  # BOARD FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  newGameSetup: () ->
    corp = new Corp(@corp, @_id)
    @incTurnCounter()
    @logForBothSides 'Starting a new game.'
    corp.startTurn()


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
        target = new Server( @corp.deck, @_id )
      when 'corpHand'
        target = new Server( @corp.hand, @_id )
      when 'corpDiscard'
        target = new Server( @corp.discard, @_id )
      else
        target = new Server( _.find(@corp.remoteServers, (obj) -> return obj._id is targetId), @_id )

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


  drawCards: (playerObj, amount) ->
    i = 0

    while i < amount
      cardObj = @getNthCardFromDeck playerObj, i+1
      if cardObj
        @moveTopCardFromDeckToHand playerObj, cardObj
      else
        console.log "Can not draw. Deck is empty."
      i++


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
