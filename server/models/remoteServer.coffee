{@Server} = require './_server' unless Meteor?

class @RemoteServer extends @Server
  constructor: (serverId, gameId) ->
    @id = serverId
    @gameId = gameId
    @name = 'Remote Server ' + serverId.substring(12)


  getICE: () ->
    game = Games.findOne @gameId
    self = _.find( game.corp.remoteServers, (obj) => obj._id is @id )
    return self.ICE


  findICE: (cardId) ->
    return _.find( @ICE, (obj) -> obj._id is cardId )


  pushICE: (card) ->
    card.loc = 'remoteServer'
    card.rezzed = false

    Games.update
      _id: @gameId
      "corp.remoteServers._id": @id
    ,
      $push:
        "corp.remoteServers.$.ICE": card


  addAsset: (card) ->
    card.loc = 'remoteServer'
    card.rezzed = false

    Games.update
      _id: @gameId
      "corp.remoteServers._id": @id
    ,
      $push:
        "corp.remoteServers.$.assetsAndAgendas": card


  hasAssetOrAgenda: () ->
    game = Games.findOne @gameId
    self = _.find( game.corp.remoteServers, (obj) => obj._id is @id )

    return self?.assetsAndAgendas.length || false
