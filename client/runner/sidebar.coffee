Template.sidebar.events "click button#draw_card": ->
  Meteor.call "drawCard", myself()

Template.sidebar.events "click button.action-button": (e) ->
  selectedCard = Session.get "selectedCard"
  
  gameLoc = selectedCard.gameLoc   # e.g. "runner.deck" or "corp.hand"
  cardId = selectedCard._id        # e.g. "sure-gamble-1"
  action = e.target.dataset.action # e.g. "draw9Credits"

  Meteor.call "doCardAction", myself(), gameLoc, cardId, action
