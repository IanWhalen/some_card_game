Template.sidebar.events "click button#drawCard": ->
  Meteor.call "doDrawAction", myself()


Template.sidebar.events "click button#gainCredit": ->
  Meteor.call "doCreditGainAction", myself()


Template.sidebar.events "click button#endTurn": ->
  Meteor.call "doEndTurnAction", myself()


Template.sidebar.events "click button.action-button": (e) ->
  selectedCard = Session.get "selectedCard"
  
  gameLoc = selectedCard.gameLoc              # runner.deck
  cardId = selectedCard._id                   # sure-gamble-1
  action = e.target.dataset.action            # draw9Credits
  remoteServer = selectedCard.remoteServer    # remoteServer1

  switch action
    when 'installResource'
      Meteor.call 'doInstallResourceAction', myself(), cardId, (err, result) ->
        console.log 'got to installResource'
        console.log err if err
    when 'installHardware'
      Meteor.call 'doInstallHardwareAction', myself(), gameLoc, cardId, (err, result) ->
        console.log err if err
    when 'installAssetToNewRemoteServer'
      Meteor.call 'createNewRemoteServer', myself(), (err, result) ->
        console.log err if err

        newServer = result
        Meteor.call 'doInstallAssetAction', myself(), cardId, newServer, (err, result) ->
          console.log err if err
    when 'rezAsset'
      Meteor.call 'doRezAssetAction', myself(), cardId, remoteServer, (err, result) ->
        console.log err if err
    else
      Meteor.call "doCardAction", myself(), cardId, action, (err, result) ->
        console.log err if err
        console.log 'got to doCardAction'

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
