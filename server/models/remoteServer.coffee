class @RemoteServer extends @Server
  constructor: (serverId, gameId) ->
    @id = serverId
    @gameId = gameId

  findICE: (cardId) ->
    return _.find( @ICE, (obj) -> obj._id is cardId )
