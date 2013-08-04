class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  newGameSetup: () ->
    corp = new Corp(@['corp'], @._id)
    corp.startTurn()
    @incTurnCounter()
    @logForBothSides 'Starting a new game.'
    @logForBothSides '===== It is now the Corp\'s turn. ====='


  #-----------------------------------------------------------------------------
  # CARD FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  getCardFromCorrectLocation: (gameLoc, cardId) ->
    side = gameLoc.split(".")[0]; # e.g. "runner"
    loc = gameLoc.split(".")[1];  # e.g. "hand" or "deck"

    cardObj = _.find @[side][loc], (obj) ->
      obj._id is cardId
    cardObj['gameLoc'] = gameLoc

    cardObj


  doCardAction: (playerObj, gameLoc, cardId, action) ->
    if playerObj.side is 'corp'
      player = new Corp(@[playerObj.side], @._id)
    if playerObj.side is 'runner'
      player = new Runner(@[playerObj.side], @._id)
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)

    actionData = cardObj.getActionDataFromCard action if cardObj?
    creditCost = actionData['credit_cost']
    clickCost = actionData['click_cost']

    if player.hasEnoughClicks(clickCost) and player.hasEnoughCredits(creditCost)
      player.payAllCosts actionData['click_cost'], actionData['credit_cost']
      result = player[action](cardObj)

      if cardObj.counters <= 0 and cardObj.trashIfNoCounters?
        @moveCardToDiscard cardObj

      if cardObj.cardType in ['Event', 'Operation']
        @moveCardToDiscard cardObj

    return result


  #-----------------------------------------------------------------------------
  # RUNNER CARD ACTIONS
  #
  #-----------------------------------------------------------------------------

  installResource: (playerObj, gameLoc, cardId, costMod) ->
    runner = new Runner(@['runner'], @['_id'])
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard 'installResource' if cardObj?

    [clickCost, creditCost, logs] = @applyCostMods actionData, costMod
    if not runner.hasEnoughClicks clickCost
      @logForRunner "You can not install #{cardObj.name} because you do not have enough clicks left."
      return false

    if not runner.hasEnoughCredits creditCost
      @logForRunner "You can not install #{cardObj.name} because you do not have enough credits left."
      return false
    
    runner.payAllCosts clickCost, creditCost
    @[cardObj['addBenefit']]() if cardObj['addBenefit']?
    @moveCardToResources cardObj
    
    line = "The Runner spends #{actionData["click_cost"]} click and " +
      "€#{actionData['credit_cost']} to install #{cardObj.name}."
    @logForBothSides line


  installHardware: (playerObj, gameLoc, cardId, costMod) ->
    runner = new Runner(@['runner'], @['_id'])
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard 'installHardware' if cardObj?

    [clickCost, creditCost, logs] = @applyCostMods actionData, costMod

    if not runner.hasEnoughClicks clickCost
      @logForRunner "You can not install #{cardObj.name} because you do not have enough clicks left."
      return false

    if not runner.hasEnoughCredits creditCost
      @logForRunner "You can not install #{cardObj.name} because you do not have enough credits left."
      return false

    runner.payAllCosts clickCost, creditCost
    @[cardObj['addBenefit']]() if cardObj['addBenefit']?
    @moveCardToHardware cardObj
    
    @logForBothSides(line) for line in logs
    @logForBothSides "The Runner spends #{clickCost} click and €#{creditCost} to install #{cardObj.name}."


  #-----------------------------------------------------------------------------
  # RUNNER BENEFITS
  #
  #-----------------------------------------------------------------------------

  add1Link: () ->
    @incLink 1


  add1Memory: () ->
    @incMemory 1


  incLink: (amount) ->
    @_incIntegerField 'runner.stats.link', amount


  incMemory: (amount) ->
    @_incIntegerField 'runner.stats.memory', amount


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
    updateHand = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    updateHand["runner.hand"] = idObj

    updateResources = {};
    cardObj['gameLoc'] = 'runner.resources'
    updateResources["runner.resources"] = cardObj

    Games.update(@._id, { $pull:  updateHand});
    Games.update(@._id, { $push: updateResources});


  moveCardToHardware: (cardObj) ->
    updateHand = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    updateHand["runner.hand"] = idObj

    updateHardware = {};
    cardObj['gameLoc'] = 'runner.hardware'
    updateHardware["runner.hardware"] = cardObj

    Games.update(@._id, { $pull:  updateHand});
    Games.update(@._id, { $push: updateHardware});


  moveCardToDiscard: (cardObj) ->
    target = cardObj.getSide() + '.discard'

    startLoc = {}
    idObj = {}
    idObj['_id'] = cardObj['_id']
    startLoc[cardObj['gameLoc']] = idObj

    updateDiscard = {}
    cardObj['gameLoc'] = target
    updateDiscard[target] = cardObj      

    Games.update( @._id, { $pull: startLoc } )
    Games.update( @._id, { $push: updateDiscard } )


  moveTopCardFromDeckToHand: (playerObj, cardObj) ->
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

  applyCostMods: (actionData, costMod) ->
    logs = []
    clickCost = actionData['click_cost']
    creditCost = actionData['credit_cost']

    if costMod is 'Modded'
      clickCost = @applyClickMod clickCost, -1
      creditCost = @applyCreditMod creditCost, -3
      logs.push 'Modded made this install cheaper by up to 3 credits.'
    
    if @['runner']['identity']['reduceFirstProgramOrHardwareInstallCostBy1']
      creditCost = @applyCreditMod creditCost, -1
      @setBooleanField 'runner.identity.reduceFirstProgramOrHardwareInstallCostBy1', false
      logs.push "Runner's identity made this install cheaper by up to 1 credit."

    return [clickCost, creditCost, logs]

  applyClickMod: (clickCost, clickMod) ->
    clickCost += clickMod
    if clickCost < 0 then return 0 else return clickCost


  applyCreditMod: (creditCost, creditMod) ->
    creditCost += creditMod
    if creditCost < 0 then return 0 else return creditCost


  payAllCosts: (playerObj, creditCost, clickCost) ->
    @incCredits playerObj, -1 * creditCost
    @incClicks playerObj, -1 * clickCost


  setPlayerClicksToZero: (playerObj) ->
    @setIntegerField playerObj.side + ".stats.clicks", 0


  resetCorpClicks: () ->
    @setIntegerField "corp.stats.clicks", 3


  resetRunnerClicks: () ->
    @setIntegerField "runner.stats.clicks", 4


  playerHasResources: (playerObj, actionData) ->
    creditCost = actionData['credit_cost']
    clickCost = actionData['click_cost']

    if @playerHasCredits playerObj.side, creditCost
      if @playerHasClicks playerObj.side, clickCost
        return true


  playerHasCredits: (side, creditCost) ->
    return @[side]['stats']['credits'] >= creditCost


  playerHasClicks: (side, clickCost) ->
    return @[side]['stats']['clicks'] >= clickCost


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
