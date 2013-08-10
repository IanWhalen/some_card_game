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
  target = e.target.dataset?.target           # newRemoteServer
  remoteServer = selectedCard.remoteServer    # remoteServer1

  switch action
    #######
    # ICE #
    #######
    when 'installICE'
      if target is 'newServer'
        Meteor.call 'createNewRemoteServer', myself(), (err, result) ->
          console.log err if err
          newServer = result
          Meteor.call 'doInstallICEAction', myself(), cardId, newServer, (err, result) ->
            console.log err if err
      else
        Meteor.call 'doInstallICEAction', myself(), cardId, target, (err, result) ->
            console.log err if err
    when 'rezICE'
      Meteor.call 'doRezICEAction', myself(), cardId, remoteServer, (err, result) ->
        console.log err if err
    #############
    # RESOURCES #
    #############
    when 'installResource'
      Meteor.call 'doInstallResourceAction', myself(), cardId, (err, result) ->
        console.log err if err
    ############
    # HARDWARE #
    ############
    when 'installHardware'
      Meteor.call 'doInstallHardwareAction', myself(), cardId, (err, result) ->
        console.log err if err
    ##########
    # ASSETS #
    ##########
    when 'installAsset'
      if target is 'newServer'
        Meteor.call 'createNewRemoteServer', myself(), (err, result) ->
          console.log err if err
          newServer = result
          Meteor.call 'doInstallAssetAction', myself(), cardId, newServer, (err, result) ->
            console.log err if err
      else
        Meteor.call 'doInstallAssetAction', myself(), cardId, target, (err, result) ->
            console.log err if err
    when 'rezAsset'
      Meteor.call 'doRezAssetAction', myself(), cardId, remoteServer, (err, result) ->
        console.log err if err
    ###################
    # EVERYTHING ELSE #
    ###################
    else
      Meteor.call "doCardAction", myself(), cardId, action, (err, result) ->
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
