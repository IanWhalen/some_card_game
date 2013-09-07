class @Deck extends @Server
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId


  getCards: () ->
    game = Games.findOne @gameId
    return game.corp.deck.cards


  popCard: () ->
    game = Games.findOne @gameId
    card = game[@owner]['deck']['cards'].pop()

    updateDeck = {}
    updateDeck[@owner + '.deck.cards'] = 1
    Games.update @gameId,
        $pop: updateDeck

    return card
