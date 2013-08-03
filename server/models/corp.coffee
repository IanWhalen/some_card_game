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


  #-----------------------------------------------------------------------------
  # ACTION FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  draw1Card: () ->
    @drawCards 1


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  resetClicks: () ->
    @setIntegerField "corp.stats.clicks", 3


  #-----------------------------------------------------------------------------
  # HELPER FUNCTIONS
  #
  #-----------------------------------------------------------------------------

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
  # CARD MOVEMENT FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  moveTopCardFromDeckToHand: (cardObj) ->
    updateDeck = {}
    updateHand = {}

    updateDeck["corp.deck"] = 1
    updateHand["corp.hand"] = cardObj

    console.log updateDeck
    console.log updateHand
    Games.update( @gameId, { $pop:  updateDeck } )
    Games.update( @gameId, { $push: updateHand } )
