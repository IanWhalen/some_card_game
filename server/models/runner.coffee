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


  #-----------------------------------------------------------------------------
  # HELPER FUNCTIONS
  #
  #-----------------------------------------------------------------------------


  #-----------------------------------------------------------------------------
  # ECONOMY FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  resetClicks: () -> @setIntegerField 'runner.stats.clicks', 4

  incClicks: (amount) -> @_incIntegerField 'runner.stats.clicks', amount

  incCredits: (amount) -> @_incIntegerField 'runner.stats.credits', amount

  incLink: (amount) -> @_incIntegerField 'runner.stats.link', amount

  incMemory: (amount) -> @_incIntegerField 'runner.stats.memory', amount


  #-----------------------------------------------------------------------------
  # CARD ACTIONS (CORE SET)
  #
  #-----------------------------------------------------------------------------

  useArmitageCodebusting: (cardObj) ->
    line = switch
      when cardObj.counters is 1
        @incCredits 1
        line = 'The Runner spends 1 click to use Armitage Codebusting and gain 1 credit.'
      when cardObj.counters >= 2
        @incCredits 2
        line = 'The Runner spends 1 click to use Armitage Codebusting and gain 2 credits.'

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
    updateDeck = {}
    updateHand = {}

    updateDeck["runner.deck"] = 1
    updateHand["runner.hand"] = cardObj

    Games.update( @gameId, { $pop:  updateDeck } )
    Games.update( @gameId, { $push: updateHand } )
