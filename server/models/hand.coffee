class @Hand
  constructor: (owner, gameId) ->
    @owner = owner
    @gameId = gameId


  getCards: () ->
    game = Games.findOne @gameId
    return game[@owner]['hand']['cards']


  pushCard: (card) ->
    card.loc = 'hand'
    card.owner = @owner

    updateHand = {}
    updateHand[@owner + '.hand.cards'] = card
    Games.update @gameId,
        $push: updateHand


  popCard: (card) ->
    updateHand = {}
    idObj = {}
    idObj['_id'] = card['_id']
    updateHand[@owner + '.hand.cards'] = idObj
    
    Games.update @gameId,
      $pull: updateHand


  getICE: () ->
    if @owner is 'corp'
      game = Games.findOne @gameId
      return game.corp.hand.ICE


  pushICE: (card) ->
    if @owner is 'corp'
      card.loc = 'hand'
      card.rezzed = false
      card.owner = @owner

      updateHand = {}
      updateHand[@owner + '.hand.ICE'] = card
      Games.update @gameId,
        $push: updateHand
