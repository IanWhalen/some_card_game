class @Server
  constructor: (obj) ->
    for key, value of obj
      @[key] = value

  findICE: (cardId) ->
    return _.find( @ICE, (obj) -> obj._id is cardId )
