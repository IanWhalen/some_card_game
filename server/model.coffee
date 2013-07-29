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

    _.find @[side][loc], (obj) ->
      obj._id is cardId


  #-----------------------------------------------------------------------------
  # RUNNER FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  installResource: (playerObj, gameLoc, cardId) ->
    cardObj = new Card(@.getCardFromCorrectLocation gameLoc, cardId)
    actionData = cardObj.getActionDataFromCard 'installResource' if cardObj?
    
    if @playerHasResources playerObj, actionData
      @payAllCosts playerObj, actionData['credit_cost'], actionData['click_cost']
      @[cardObj['addBenefit']]() if cardObj['addBenefit']?
      @moveCardToResources cardObj

      line = "The Runner spends " + actionData["click_cost"] + " click and €" +
        actionData['credit_cost'] + " to install " + cardObj.name + "."
      @logForBothSides line


  add1Link: () ->
    @incLink 1


  incLink: (amount) ->
    @incIntegerField 'runner.stats.link', amount


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveCardToResources: (cardObj) ->
    updateHand = {};
    updateHand["runner.hand"] = cardObj;

    updateResources = {};
    updateResources["runner.resources"] = cardObj;

    Games.update(@._id, { $pull:  updateHand});
    Games.update(@._id, { $push: updateResources});


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  payAllCosts: (playerObj, creditCost, clickCost) ->
    @incCredits(playerObj, -1 * creditCost);
    @incClicks(playerObj, -1 * clickCost);


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
    if @playerHasCredits playerObj.side, actionData
      if @playerHasClicks playerObj.side, actionData
        return true


  playerHasCredits: (side, actionData) ->
    if @[side]['stats']['credits'] >= actionData['credit_cost']
      return true


  playerHasClicks: (side, actionData) ->
    if @[side]['stats']['clicks'] >= actionData['click_cost']
      return true


  #-----------------------------------------------------------------------------
  # LOGGING FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  logForBothSides: (line) ->
    @.addLogLineToSide('corp', line);
    @.addLogLineToSide('runner', line);


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  setCurrentPlayerField: (playerId) ->
    Games.update @._id,
      $set: { current_player : playerId }


  incIntegerField: (targetField, amount) ->
    modObj = {};
    modObj[targetField] = amount;

    Games.update @._id,
      $inc: modObj


  setIntegerField: (targetField, amount) ->
    modObj = {}
    modObj[targetField] = amount

    Games.update @._id,
      $set: modObj


  addLogLineToSide: (side, line) ->
    modObj = {}
    targetField = side + '.logs'
    modObj[targetField] = line

    Games.update @._id,
      $push: modObj