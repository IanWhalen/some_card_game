class @Hand
  constructor: (arr, owner, gameId) ->
    @cards = arr
    @owner = owner
    @gameId = gameId


  pushCard: (card) ->
    card.loc = 'hand'
    card.owner = @owner

    updateHand = {}
    updateHand[@owner + '.hand'] = card
    Games.update @gameId,
        $push: updateHand
