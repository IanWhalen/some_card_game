class @Deck
  constructor: (obj, owner, gameId) ->
    @cards = obj
    @owner = owner
    @gameId = gameId


  popCard: () ->
    game = Games.findOne @gameId
    card = game[@owner]['deck'].pop()

    updateDeck = {}
    updateDeck[@owner + '.deck'] = 1
    Games.update @gameId,
        $pop: updateDeck

    return card
