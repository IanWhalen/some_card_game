class @Corp extends @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value
    @['gameId'] = gameId


  #-----------------------------------------------------------------------------
  # GAME PROCESS FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  startTurn: () ->
    @resetClicks()
    @draw1Card()


  #-----------------------------------------------------------------------------
  # CARD ACTIONS (CORE SET)
  #
  #-----------------------------------------------------------------------------

  useHedgeFund: () ->
    @add9Credits()
    @logForBothSides 'The Corp spends 1 click and 5 credits to use Hedge Fund and gain 9 credits.'


  useBioticLabor: () ->
    @add2Clicks()
    @logForBothSides 'The Corp spends 1 click and 4 credits to use Biotic Labor and gain 2 clicks.'


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  resetClicks: () -> @setIntegerField "corp.stats.clicks", 3

  incClicks: (amount) -> @_incIntegerField 'corp.stats.clicks', amount

  incCredits: (amount) -> @_incIntegerField 'corp.stats.credits', amount

  applyCostMods: (actionData, costMod) ->
    logs = []
    clickCost = actionData['click_cost']
    creditCost = actionData['credit_cost']

    return [clickCost, creditCost, logs]

  #-----------------------------------------------------------------------------
  # CORP ACTIONS
  #
  #-----------------------------------------------------------------------------

  installAsset: (cardId, server) ->
    cardObj = _.find @['hand'], (obj) -> obj._id is cardId
    cardObj['rezzed'] = false
    cardObj['loc'] = 'assets'

    @moveCardToServer cardObj, server



  #-----------------------------------------------------------------------------
  # CARD MOVEMENT FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveTopCardFromDeckToHand: (cardObj) ->
    cardObj['gameLoc'] = 'corp.hand'
    cardObj.loc = 'hand'

    updateDeck = {}
    updateHand = {}

    updateDeck["corp.deck"] = 1
    updateHand["corp.hand"] = cardObj

    Games.update( @gameId, { $pop:  updateDeck } )
    Games.update( @gameId, { $push: updateHand } )


  moveCardToServer: (cardObj, server) ->
    updateHand = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    updateHand["corp.hand"] = idObj

    @addAssetToRemoteServer cardObj, server['action']
    @removeCardFromHand updateHand


  #-----------------------------------------------------------------------------
  # LOGGING FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  logForSelf: (line) ->
    @logForCorp line


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  addAssetToRemoteServer: (cardObj, serverId) ->
    Games.update
      _id: @gameId
      "corp.remoteServers.action": serverId
    ,
      $push:
        "corp.remoteServers.$.assetsAndAgendas": cardObj