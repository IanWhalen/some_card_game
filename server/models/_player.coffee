class @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value
    @gameId = gameId


  #-----------------------------------------------------------------------------
  # GAME PROCESS FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  canEndTurn: () ->
    return false if @hand.length > @stats.handLimit
    true


  #-----------------------------------------------------------------------------
  # CARD ACTIONS (SHARED)
  #
  #-----------------------------------------------------------------------------

  add2Clicks: () -> @incClicks 2

  add1Credit: () -> @incCredits 1

  add9Credits: () -> @incCredits 9

  draw1Card: () -> @drawCards 1

  draw3Cards: () -> @drawCards 3

  draw5Cards: () -> @drawCards 5

  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  hasEnoughCredits: (n) -> @stats.credits >= n

  hasEnoughClicks: (n) -> @stats.clicks >= n

  applyClickMod: (clickCost, clickMod) ->
    clickCost += clickMod
    if clickCost < 0 then return 0 else return clickCost


  applyCreditMod: (creditCost, creditMod) ->
    creditCost += creditMod
    if creditCost < 0 then return 0 else return creditCost


  #-----------------------------------------------------------------------------
  # HELPER FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  setIntegerField: (targetField, amount) -> @_setField targetField, amount

  logForBothSides: (line) ->
    @logForRunner line
    @logForCorp line


  logForRunner: (line) -> @_addLogLineToSide 'runner', line

  logForCorp: (line) -> @_addLogLineToSide 'corp', line

  setBooleanField: (targetField, bool) -> @_setField targetField, bool

  payAllCosts: (clickCost, creditCost) ->
    @incClicks -1 * clickCost
    @incCredits -1 * creditCost


  drawCards: (amount) ->
    deck = new Deck(@side, @gameId)
    hand = new Hand(@side, @gameId)

    i = 0
    while i < amount
      card = deck.popCard()
      hand.pushCard( card ) if card
      i++


  discardFromHand: (cardId) ->
    card = new Card( _.find @hand, (obj) -> obj._id is cardId )
    @_discardCard card

    @logForBothSides "The player discards 1 card."


  getHand: () ->
    hand = new Hand(@side, @gameId)
    console.log hand
    return hand.getCards()


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  _incIntegerField: (targetField, amount) ->
    modObj = {}
    modObj[targetField] = amount

    Games.update @gameId,
      $inc: modObj


  _setField: (targetField, value) ->
    modObj = {}
    modObj[targetField] = value

    Games.update @gameId,
      $set: modObj


  _addLogLineToSide: (side, line) ->
    modObj = {}
    targetField = side + '.logs'
    modObj[targetField] = line

    Games.update @gameId,
      $push: modObj


  removeCardFromHand: (updateObj) ->
    Games.update @gameId,
      $pull: updateObj


  _discardCard: (card) ->
    target = card.owner + '.discard'                  # 'corp.discard' or 'runner.discard'

    updateStart = {}
    idObj = {}
    idObj._id = card._id                              # { _id: 'sure-gamble-1' }
    updateStart["#{card.owner}.#{card.loc}"] = idObj  # { 'runner.hand' : { _id : 'sure-gamble-1' } }

    Games.update @gameId,                             # Remove card from starting location
      $pull: updateStart


    updateDiscard = {}
    card.loc = 'discard'
    card.faceDown = true                              # Mark as faceDown so display logic keeps hidden
    updateDiscard[target] = card                      # { 'runner.discard': card }

    Games.update @gameId,                             # Add card to top of Discard
      $push: updateDiscard
