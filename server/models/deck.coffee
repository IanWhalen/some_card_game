class @Deck
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId


  getCards: () ->
    game = Games.findOne @gameId
    return game.corp.deck


  popCard: () ->
    game = Games.findOne @gameId
    card = game[@owner]['deck'].pop()

    updateDeck = {}
    updateDeck[@owner + '.deck'] = 1
    Games.update @gameId,
        $pop: updateDeck

    return card
