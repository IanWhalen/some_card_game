{@Server} = require './_server' unless Meteor?

class @Deck extends @Server
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId

    @name = 'R&D' if owner is 'corp'
    @name = 'Stack' if owner is 'runner'


  getCards: () ->
    game = Games.findOne @gameId
    return game.corp.deck.cards


  getICE: () ->
    if @owner is 'corp'
      game = Games.findOne @gameId
      return game.corp.deck.ICE


  popCard: () ->
    game = Games.findOne @gameId
    card = game[@owner]['deck']['cards'].pop()

    updateDeck = {}
    updateDeck[@owner + '.deck.cards'] = 1
    Games.update @gameId,
        $pop: updateDeck

    return card


  pushICE: (card) ->
    if @owner is 'corp'
      card.loc = 'deck'
      card.rezzed = false
      card.owner = @owner

      updateDeck = {}
      updateDeck[@owner + '.deck.ICE'] = card
      Games.update @gameId,
          $push: updateDeck
