{@Player} = require './_player' unless Meteor?

class @Corp extends @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value

    @gameId = gameId
    @deck = new Deck( @deck, 'corp', @gameId )
    @hand = new Hand( @hand, 'corp', @gameId )

  #-----------------------------------------------------------------------------
  # GAME PROCESS FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  startGame: () ->
    @draw5Cards()
    @startTurn()


  startTurn: () ->
    @logForBothSides "===== It is now the Corp's turn. ====="
    
    # Corp automatically draws a card by default
    @draw1Card()
    @logForBothSides 'The Corp draws 1 card automatically.'

    # Update all 1-per-turn values
    @resetClicks()
    @setBooleanField 'corp.identity.gain1CreditOnFirstInstall', true
    
    # Execute various conditional benefits
    @add1Credit() if @identity.gain1CreditEachTurn


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

  setClicksToZero: () -> @setIntegerField 'corp.stats.clicks', 0

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

  installICE: (cardId, server) ->
    card = new Card( _.find @hand, (obj) -> obj._id is cardId )
    game = new Game (Games.findOne(@gameId))
    actionData = card.getActionDataFromCard 'installICE' if card?

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    creditCost += server?.ICE?.length ? 0

    if not @hasEnoughClicks clickCost
      @logForSelf "You can't install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can't install #{card.name} because you do not have enough credits left."
      return false

    if server is 'newServer'
      server = game.createNewRemoteServer()
    
    @payAllCosts clickCost, creditCost
    line = "The Corp spends #{clickCost} click to install ICE on #{server.name}."
    @logForBothSides line

    card.rezzed = false
    card.loc = 'remoteServer'
    @moveICEToServer card, server


  rezICE: (cardId, serverName) ->
    serverObj = _.find( @remoteServers, (i) -> i._id is serverName )
    server = new Server( serverObj, @gameId )
    card = new Card( server.findICE(cardId) )
    actionData = card.getActionDataFromCard 'rezICE'

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false

    @payAllCosts clickCost, creditCost
    line = "The Runner spends #{clickCost} clicks and €#{creditCost} to rez #{card.name}."
    @logForBothSides line

    @[card.addBenefit]() if card.addBenefit?
    card.rezzed = true

    ICE = _.map(server.ICE, (card) ->
      card.rezzed = true if card._id is cardId
      return card
    )

    @updateICEOnRemoteServer server._id, ICE


  installAsset: (cardId, server) ->
    card = new Card( _.find @hand, (obj) -> obj._id is cardId )
    game = new Game (Games.findOne(@gameId))
    actionData = card.getActionDataFromCard 'installAsset' if card?

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false
    
    if server is 'newServer'
      server = game.createNewRemoteServer()
    
    if server.assetsAndAgendas.length > 0
      @logForSelf "You can't install #{card.name} because a card is already installed on that server."
      return false

    @payAllCosts clickCost, creditCost
    line = "The Corp spends #{clickCost} click to install a card to #{server.name}."
    @logForBothSides line

    card.rezzed = false
    card.loc = 'remoteServer'
    @moveCardToServer card, server


  rezAsset: (cardId, serverName) ->
    server = _.find( @remoteServers, (i) -> i._id is serverName)
    card = new Card( server.assetsAndAgendas[0] )
    actionData = card.getActionDataFromCard 'rezAsset' if card

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false

    @payAllCosts clickCost, creditCost
    line = "The Runner spends #{clickCost} clicks and €#{creditCost} to rez #{card.name}."
    @logForBothSides line

    @[card.addBenefit]() if card.addBenefit?
    card.rezzed = true
    @updateAssetOnRemoteServer "corp.remoteServers.#{server.name}.assetsAndAgendas", card


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
    cardObj.loc = 'hand'

    updateDeck = {}
    updateHand = {}

    updateDeck["corp.deck"] = 1
    updateHand["corp.hand"] = cardObj

    Games.update( @gameId, { $pop:  updateDeck } )
    Games.update( @gameId, { $push: updateHand } )


  moveCardToServer: (cardObj, server) ->
    cardObj.remoteServer = server._id
    updateHand = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    updateHand["corp.hand"] = idObj

    @addAssetToRemoteServer cardObj, server._id
    @removeCardFromHand updateHand


  moveICEToServer: (card, server) ->
    card.remoteServer = server._id
    updateHand = {}
    idObj = {}
    idObj._id = card._id
    updateHand["corp.hand"] = idObj

    @addICEToRemoteServer card, server._id
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
      "corp.remoteServers._id": serverId
    ,
      $push:
        "corp.remoteServers.$.assetsAndAgendas": cardObj


  addICEToRemoteServer: (card, serverId) ->
    Games.update
      _id: @gameId
      "corp.remoteServers._id": serverId
    ,
      $push:
        "corp.remoteServers.$.ICE": card


  updateAssetOnRemoteServer: (target, card) ->
    updateLocation = {}
    idObj = {}
    idObj._id = card._id
    updateLocation[target] = idObj

    Games.update
      _id: @gameId
      "corp.remoteServers._id": card.remoteServer
    ,
      $set:
        "corp.remoteServers.$.assetsAndAgendas": [card]


  updateICEOnRemoteServer: (remoteServer, ICE) ->
    Games.update
      _id: @gameId
      "corp.remoteServers._id": remoteServer
    ,
      $set:
        "corp.remoteServers.$.ICE": ICE
