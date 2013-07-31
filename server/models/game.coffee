class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


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
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard action if cardObj?

    if @playerHasResources playerObj, actionData
      @payAllCosts playerObj, actionData['credit_cost'], actionData['click_cost']
      @[action](playerObj, cardObj)

      if cardObj.counters <= 0 and cardObj.trashIfNoCounters?
        @moveCardToDiscard cardObj

      if cardObj.cardType in ['Event', 'Operation']
        @moveCardToDiscard cardObj


  #-----------------------------------------------------------------------------
  # RUNNER CARD ACTIONS
  #
  #-----------------------------------------------------------------------------

  installResource: (playerObj, gameLoc, cardId) ->
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard 'installResource' if cardObj?
    
    if @playerHasResources playerObj, actionData
      @payAllCosts playerObj, actionData['credit_cost'], actionData['click_cost']
      @[cardObj['addBenefit']]() if cardObj['addBenefit']?
      @moveCardToResources cardObj
      
      line = "The Runner spends #{actionData["click_cost"]} click and " +
        "€#{actionData['credit_cost']} to install #{cardObj.name}."
      @logForBothSides line


  installHardware: (playerObj, gameLoc, cardId) ->
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard 'installHardware' if cardObj?
    
    creditCost = actionData['credit_cost']
    clickCost = actionData['click_cost']

    if not @playerHasClicks playerObj.side, clickCost
      @logForRunner 'You can not install #{cardObj.name} because you do not have enough clicks left.'
      return false

    if @['runner']['identity']['reduceFirstProgramOrHardwareInstallCostBy1']
      creditCost -= 1 unless creditCost == 0
      if not @playerHasCredits playerObj.side, creditCost
        @logForRunner 'You can not install this card because you do not have enough credits left.'
        return false

      @logForBothSides 'Cost of Runner\'s hardware installation was reduced by 1 credit.'
      @setBooleanField 'runner.identity.reduceFirstProgramOrHardwareInstallCostBy1', false

    if not @playerHasCredits playerObj.side, creditCost
        @logForRunner 'You can not install this card because you do not have enough credits left.'
        return false

    @payAllCosts playerObj, creditCost, clickCost
    @[cardObj['addBenefit']]() if cardObj['addBenefit']?
    @moveCardToHardware cardObj
    
    @logForBothSides "The Runner spends #{actionData["click_cost"]} click and " +
      "€#{actionData['credit_cost']} to install #{cardObj.name}."


  useArmitageCodebusting: (playerObj, cardObj) ->
    line = switch
      when cardObj.counters >= 2
        @incCredits playerObj, 2
        cardObj.incCounters(@._id, -2)
        line = 'The Runner spends 1 click to use Armitage Codebusting and gain 2 credits.'

      when cardObj.counters == 1
        @incCredits playerObj, 1
        cardObj.incCounters(@._id, -1)
        line = 'The Runner spends 1 click to use Armitage Codebusting and gain 1 credit.'

    @logForBothSides line


  #-----------------------------------------------------------------------------
  # RUNNER BENEFITS
  #
  #-----------------------------------------------------------------------------

  add1Link: () ->
    @incLink 1


  add1Memory: () ->
    @incMemory 1


  incLink: (amount) ->
    @incIntegerField 'runner.stats.link', amount


  incMemory: (amount) ->
    @incIntegerField 'runner.stats.memory', amount


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

    updateDiscard = {};
    cardObj['gameLoc'] = target
    updateDiscard[target] = cardObj      

    Games.update(@._id, { $pull:  startLoc});
    Games.update(@._id, { $push: updateDiscard});

    line = cardObj.name + ' was moved to the discard pile.'
    @logForBothSides line


  moveTopCardFromDeckToHand: (playerObj, cardObj) ->
    updateDeck = {}
    updateHand = {}

    updateDeck[playerObj.side + ".deck"] = 1
    updateHand[playerObj.side + ".hand"] = cardObj

    Games.update(@._id, {$pop:  updateDeck});
    Games.update(@._id, {$push: updateHand});


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

  payAllCosts: (playerObj, creditCost, clickCost) ->
    @incCredits playerObj, -1 * creditCost
    @incClicks playerObj, -1 * clickCost


  incCredits: (playerObj, amount) ->
    targetField = playerObj.side + ".stats.credits"
    @incIntegerField targetField, amount


  incClicks: (playerObj, amount) ->
    targetField = playerObj.side + ".stats.clicks"
    @incIntegerField targetField, amount


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
    @incIntegerField 'turn', 1


  setCurrentPlayerField: (playerId) ->
    @setField 'current_player', playerId


  setBooleanField: (targetField, bool) ->
    @setField targetField, bool


  setIntegerField: (targetField, amount) ->
    @setField targetField, amount


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  incIntegerField: (targetField, amount) ->
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


  setField: (targetField, value) ->
    modObj = {}
    modObj[targetField] = value

    Games.update @._id,
      $set: modObj
