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
    @add1Credit() if @identity.gain1CreditEachTurn
    @setBooleanField 'corp.identity.gain1CreditOnFirstInstall', true


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

  applyMods: () ->
    if @identity.gain1CreditOnFirstInstall
      @add1Credit()
      @setBooleanField 'runner.identity.gain1CreditOnFirstInstall', false
      logs.push "Corp gained 1 credit from this install because of their identity."    


  #-----------------------------------------------------------------------------
  # CORP ACTIONS
  #
  #-----------------------------------------------------------------------------

  installAsset: (cardId, server) ->
    card = new Card( _.find @hand, (obj) -> obj._id is cardId )
    actionData = card.getActionDataFromCard 'installAsset' if card?

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false

    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false
    
    @payAllCosts clickCost, creditCost
    line = "The Runner spends #{clickCost} click and to install a card to a Remote Server."
    @logForBothSides line

    card.rezzed = false
    card.loc = 'assets'
    @moveCardToServer card, server


  #-----------------------------------------------------------------------------
  # CORP ONGOING BENEFITS
  #
  #-----------------------------------------------------------------------------

  gain1CreditEachTurn: () ->
    @setBooleanField 'corp.identity.gain1CreditEachTurn', true


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