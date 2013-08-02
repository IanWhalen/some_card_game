class @Player
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  hasEnoughCredits: (n) ->
    @['stats']['credits'] >= n


  hasEnoughClicks: (n) ->
    @['stats']['clicks'] >= n
