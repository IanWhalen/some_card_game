class @Hand
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId


  pushCard: (card) ->
    card.loc = 'hand'
    card.owner = @owner

    updateHand = {}
    updateHand[@owner + '.hand'] = card
    Games.update @gameId,
        $push: updateHand
