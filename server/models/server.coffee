class @Server
  constructor: (obj, gameId) ->
    for key, value of obj
      @[key] = value
    @['gameId'] = gameId

  findICE: (cardId) ->
    return _.find( @ICE, (obj) -> obj._id is cardId )
