{@Server} = require './_server' unless Meteor?

class @Discard extends @Server
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId

    @name = 'Archives' if owner is 'corp'
    @name = 'Heap' if owner is 'runner'


  getCards: () ->
    game = Games.findOne @gameId
    return game[@owner]['discard']['cards']


  getICE: () ->
    if @owner is 'corp'
      game = Games.findOne @gameId
      return game.corp.discard.ICE


  pushICE: (card) ->
    if @owner is 'corp'
      card.loc = 'discard'
      card.rezzed = false
      card.owner = @owner

      updateDiscard = {}
      updateDiscard[@owner + '.discard.ICE'] = card
      Games.update @gameId,
        $push: updateDiscard
