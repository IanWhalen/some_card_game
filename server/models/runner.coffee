class @Runner extends @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value
    @['gameId'] = gameId


  #-----------------------------------------------------------------------------
  # ACTION FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  add1Link: () -> @incLink 1

  add1Memory: () -> @incMemory 1

  incLink: (amount) -> @_incIntegerField 'runner.stats.link', amount

  incMemory: (amount) -> @_incIntegerField 'runner.stats.memory', amount

  installResource: (cardId, costMod) ->
    card = new Card( _.find @hand, (obj) -> obj._id is cardId )
    actionData = card.getActionDataFromCard 'installResource' if card?

    [clickCost, creditCost, logs] = @applyCostMods actionData, costMod
    if not @hasEnoughClicks clickCost
      @logForSelf "You can not install #{card.name} because you do not have enough clicks left."
      return false

    if not @hasEnoughCredits creditCost
      @logForSelf "You can not install #{card.name} because you do not have enough credits left."
      return false
    
    @payAllCosts clickCost, creditCost
    @[card.addBenefit]() if card.addBenefit?
    card.loc = 'resources'
    @moveCardToResources card
    
    line = "The Runner spends #{clickCost} click and €#{creditCost} to install #{card.name}."
    @logForBothSides line


  #-----------------------------------------------------------------------------
  # CARD MOVEMENT
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

    Games.update @gameId,                           # Remove card from Hand
      $pull: updateHand

    Games.update @gameId,                           # Add card to installed Resources
      $push: updateResources


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  resetClicks: () -> @setIntegerField 'runner.stats.clicks', 4

  incClicks: (amount) -> @_incIntegerField 'runner.stats.clicks', amount

  incCredits: (amount) -> @_incIntegerField 'runner.stats.credits', amount

  incLink: (amount) -> @_incIntegerField 'runner.stats.link', amount

  incMemory: (amount) -> @_incIntegerField 'runner.stats.memory', amount

  applyCostMods: (actionData, costMod) ->
    logs = []
    clickCost = actionData['click_cost']
    creditCost = actionData['credit_cost']

    return [clickCost, creditCost, logs]


  #-----------------------------------------------------------------------------
  # CARD ACTIONS (CORE SET)
  #
  #-----------------------------------------------------------------------------

  useArmitageCodebusting: (card) ->
    line = switch
      when card.counters is 1
        @incCredits 1
        card.incCounters(@gameId, -1)
        line = 'The Runner spends 1 click to take 1 credit from Armitage Codebusting.'
      when card.counters >= 2
        @incCredits 2
        card.incCounters(@gameId, -2)
        line = 'The Runner spends 1 click to take 2 credits from Armitage Codebusting.'

    @logForBothSides line

    return 'usedArmitageCodebusting'


  useModded: (cardObj) ->
    @setBooleanField 'runner.identity.isModded', true

    @logForBothSides 'The Runner spends 1 click to use Modded.'
    @logForBothSides 'The Runner is choosing hardware or a program to install now.'

    return 'runnerIsModded'


  useSureGamble: (cardObj) ->
    @add9Credits
    @logForBothSides 'The Runner spends 1 click and 5 credits to use Sure Gamble and gain 9 credits.'

    return 'usedSureGamble'


  useDiesel: (cardObj) ->
    @draw3Cards
    @logForBothSides 'The Runner spends 1 click to use Diesel and draw 3 cards.'

    return 'usedDiesel'


  #-----------------------------------------------------------------------------
  # CARD MOVEMENT FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveTopCardFromDeckToHand: (cardObj) ->
    cardObj['gameLoc'] = 'runner.hand'
    cardObj.loc = 'hand'

    updateDeck = {}
    updateHand = {}

    updateDeck["runner.deck"] = 1
    updateHand["runner.hand"] = cardObj

    Games.update( @gameId, { $pop:  updateDeck } )
    Games.update( @gameId, { $push: updateHand } )


  #-----------------------------------------------------------------------------
  # LOGGING FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  logForSelf: (line) ->
    @logForRunner line
