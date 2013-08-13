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
    @logForBothSides '===== It is now the Corp\'s turn. ====='
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


  #-----------------------------------------------------------------------------
  # SHARED CARD ACTIONS
  #
  #-----------------------------------------------------------------------------

  add1Credit: (playerObj) ->
    @incCredits playerObj, 1


  add9Credits: (playerObj) ->
    @incCredits playerObj, 9


  draw1Card: (playerObj) ->
    @drawCards playerObj, 1


  draw3Cards: (playerObj) ->
    @drawCards playerObj, 3


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


  moveCardToDiscard: (cardObj) ->
    target = cardObj.owner + '.discard'             # 'corp.discard' or 'runner.discard'

    startLoc = {}                                   # {}
    idObj = {}                                      # {}
    idObj._id = cardObj._id                         # { _id: 'sure-gamble-1' }
    startLoc[cardObj.owner + cardObj.loc] = idObj   # { 'runner.hand' : { _id : 'sure-gamble-1' } }

    updateDiscard = {}                              # {}
    cardObj.loc = 'discard'                         # cardObj
    updateDiscard[target] = cardObj                 # { 'runner.discard': cardObj }

    Games.update @_id,                              # Remove card from starting location
      $pull: startLoc
    
    Games.update @_id,                              # Add card to top of Discard
      $push: updateDiscard


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

  cleanBoard: () ->
    # for each in resources
    #   if no counters and trashIfNoCounters
    #     then trash


  resetRunnerData: () ->
    @resetRunnerClicks()
    
    if @['runner']['identity']['reduceFirstProgramOrHardwareInstallCostBy1']?
      @setBooleanField 'runner.identity.reduceFirstProgramOrHardwareInstallCostBy1', true


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
