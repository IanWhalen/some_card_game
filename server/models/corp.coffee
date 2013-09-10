{@Player} = require './_player' unless Meteor?

class @Corp extends @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value

    @gameId = gameId
    @side = 'corp'

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

    game = new Game(Games.findOne @gameId)
    game.incTurnCounter()


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

  installICE: (cardId, serverId) ->
    # Instantiate necessary models
    game = new Game(Games.findOne @gameId)
    hand = new Hand('corp', @gameId)
    card = new Card( _.find @getHand(), (obj) -> obj._id is cardId )

    # Get the actionData relevant to installing this ICE
    actionData = card.getActionDataFromCard 'installICE' if card?

    # Change the click and credit costs based on active modifiers
    [clickCost, creditCost, logs] = @applyCostMods actionData, false

    # Increase credit cost for each ICE already installed
    if serverId isnt 'newServer'
      if serverId is 'deck'
        server = new Deck 'corp', @gameId
      else
        server = new RemoteServer serverId, @gameId
      creditCost += server.getICE().length

    # Stop installation if player does not have enough clicks/credits
    if not @hasEnoughClicks clickCost
      @logForSelf "You can't install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can't install #{card.name} because you do not have enough credits left."
      return false

    # Create new Remote Server if necessary
    if server is 'newServer'
      server = game.createNewRemoteServer()
    
    # Pay credit and click costs for this installation
    @payAllCosts clickCost, creditCost
    line = "The Corp spends #{clickCost} click to install ICE on #{server.name}."
    @logForBothSides line

    # Move card from hand to target server in database
    hand.popCard card
    server.pushICE card


  rezICE: (cardId, serverName) ->
    serverObj = _.find( @remoteServers, (i) -> i._id is serverName )
    server = new RemoteServer( serverObj, @gameId )
    card = new Card( server.findICE(cardId) )
    actionData = card.getActionDataFromCard 'rezICE'

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not rez #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not rez #{card.name} because you do not have enough credits left."
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


  installAsset: (cardId, serverId) ->
    # Instantiate necessary models
    game = new Game (Games.findOne @gameId)
    hand = new Hand('corp', @gameId)
    card = new Card( _.find @getHand(), (obj) -> obj._id is cardId )
    
    # Get the actionData relevant to installing this asset
    actionData = card.getActionDataFromCard 'installAsset'

    # Change the click and credit costs based on active modifiers
    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    
    # Stop installation if player does not have enough clicks/credits
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false
    
    # Instantiate RemoteServer model
    if serverId is 'newServer'
      server = game.createNewRemoteServer()
    else
      server = new RemoteServer serverId, @gameId
    
    # Stop installation if player has already installed an asset or agenda here
    if server.hasAssetOrAgenda()
      @logForSelf "You can't install #{card.name} because a card is already installed on that server."
      return false

    # Pay credit and click costs for this installation
    @payAllCosts clickCost, creditCost
    line = "The Corp spends #{clickCost} click to install a card to #{server.name}."
    @logForBothSides line

    # Move card from hand to Remote Server in database
    hand.popCard card
    server.addAsset card


  rezAsset: (cardId, serverName) ->
    server = _.find( @remoteServers, (i) -> i._id is serverName)
    card = new Card( server.assetsAndAgendas[0] )
    actionData = card.getActionDataFromCard 'rezAsset' if card

    [clickCost, creditCost, logs] = @applyCostMods actionData, false
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not rez #{card.name} because you do not have enough clicks left."
      return false
    if not @hasEnoughCredits creditCost
      @logForSelf "You can not rez #{card.name} because you do not have enough credits left."
      return false

    @payAllCosts clickCost, creditCost
    line = "The Runner spends #{clickCost} clicks and €#{creditCost} to rez #{card.name}."
    @logForBothSides line

    @[card.addBenefit]() if card.addBenefit?
    card.rezzed = true
    @updateAssetOnRemoteServer "corp.remoteServers.#{server.name}.assetsAndAgendas", card


  doCardAction: (cardId, action) ->
    card = @searchAllLocsForCard cardId
    actionData = card.getActionDataFromCard action

    [clickCost, creditCost, logs] = @applyCostMods actionData, card.cardType, ''
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not use #{card.name} because you do not have enough clicks left."
      return false

    if not @hasEnoughCredits creditCost
      @logForSelf "You can not use #{card.name} because you do not have enough credits left."
      return false

    @payAllCosts clickCost, creditCost
    result = @[action](card)

    if card.counters <= 0 and card.trashIfNoCounters?
      @_discardCard card

    if card.cardType in ['Operation']
      @_discardCard card

    return result


  #-----------------------------------------------------------------------------
  # CORP ONGOING BENEFITS
  #
  #-----------------------------------------------------------------------------

  gain1CreditEachTurn: () ->
    @setBooleanField 'corp.identity.gain1CreditEachTurn', true


  #-----------------------------------------------------------------------------
  # HELPERS
  #
  #-----------------------------------------------------------------------------

  searchAllLocsForCard: (cardId) ->
    game = new Game (Games.findOne @gameId)
    allCards = _.union(@getHand())
    card = new Card _.find(allCards, (obj) -> obj._id is cardId)
    return card if card


  #-----------------------------------------------------------------------------
  # CARD MOVEMENT FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveCardToServer: (cardObj, server) ->
    cardObj.remoteServer = server._id
    updateHand = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    updateHand["corp.hand"] = idObj

    @addAssetToRemoteServer cardObj, server._id
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
