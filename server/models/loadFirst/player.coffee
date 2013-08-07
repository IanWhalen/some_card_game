class @Player
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value
    @['gameId'] = gameId


  #-----------------------------------------------------------------------------
  # CARD ACTIONS (SHARED)
  #
  #-----------------------------------------------------------------------------

  add2Clicks: () -> @incClicks 2

  add1Credit: () -> @incCredits 1

  add9Credits: () -> @incCredits 9

  draw1Card: () -> @drawCards 1

  draw3Cards: () -> @drawCards 3


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  hasEnoughCredits: (n) -> @['stats']['credits'] >= n

  hasEnoughClicks: (n) -> @['stats']['clicks'] >= n

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

  # TODO: handle empty deck
  getNthCardFromDeck: (n) -> @['deck'].slice(-1*n)[0];

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
    i = 0

    while i < amount
      cardObj = @getNthCardFromDeck i+1
      if cardObj
        @moveTopCardFromDeckToHand cardObj
      else
        console.log "Can not draw. Deck is empty."
      i++


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  _incIntegerField: (targetField, amount) ->
    modObj = {};
    modObj[targetField] = amount;

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
