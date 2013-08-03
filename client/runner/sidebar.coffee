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

  if action is 'installResource'
    Meteor.call 'doInstallResourceAction', myself(), gameLoc, cardId, (err, result) ->
      console.log err if err

  if action is 'installHardware'
    Meteor.call 'doInstallHardwareAction', myself(), gameLoc, cardId, (err, result) ->
      console.log err if err

  else
    Meteor.call "doCardAction", myself(), gameLoc, cardId, action, (err, result) ->
      console.log err if err
      
      if result is 'runnerIsModded'
        Meteor.call "getRunnerHand", myself(), (err, result) ->
          console.log err if err

          cards = _.filter(result, (card) ->
            card['cardType'] in ['Program', 'Hardware']
          )

          Session.set "programsAndHardwareInHand", cards
          Session.set 'runnerIsModded', true
          Session.set 'showDialog', true

  Session.set "selectedCard", undefined
