class @Player
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  hasEnoughCredits: (n) ->
    @['stats']['credits'] >= n


  hasEnoughClicks: (n) ->
    @['stats']['clicks'] >= n


  #-----------------------------------------------------------------------------
  # HELPER FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  getNthCardFromDeck: (n) ->
    # TODO: handle empty deck
    @['deck'].slice(-1*n)[0];


  setIntegerField: (targetField, amount) ->
    @_setField targetField, amount


  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  _setField: (targetField, value) ->
    modObj = {}
    modObj[targetField] = value

    Games.update @gameId,
      $set: modObj