class @Deck
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  getTopCard: () ->
    @slice(-1)[0]


  getNthCard: (n) ->
    @slice(-1*n)[0]
