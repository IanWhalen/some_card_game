class @Hand
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId


  getCards: () ->
    game = Games.findOne @gameId
    return game[@owner]['hand']


  pushCard: (card) ->
    card.loc = 'hand'
    card.owner = @owner

    updateHand = {}
    updateHand[@owner + '.hand'] = card
    Games.update @gameId,
        $push: updateHand
