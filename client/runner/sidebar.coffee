Template.sidebar.events "click button#drawCard": ->
  Meteor.call "doDrawAction", myself()

Template.sidebar.events "click button#gainCredit": ->
  Meteor.call "doCreditGainAction", myself()

Template.sidebar.events "click button#endTurn": ->
  Meteor.call "doEndTurnAction", myself()

Template.sidebar.events "click button.action-button": (e) ->
  selectedCard = Session.get "selectedCard"
  
  gameLoc = selectedCard.gameLoc   # e.g. "runner.deck" or "corp.hand"
  cardId = selectedCard._id        # e.g. "sure-gamble-1"
  action = e.target.dataset.action # e.g. "draw9Credits"

  Meteor.call "doCardAction", myself(), gameLoc, cardId, action
