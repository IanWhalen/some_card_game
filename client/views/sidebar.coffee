Template.sidebar.events "click button#drawCard": ->
  Meteor.call "doDrawAction", myself()


Template.sidebar.events "click button#gainCredit": ->
  Meteor.call "doCreditGainAction", myself()


Template.sidebar.events "click button#endTurn": ->
  Meteor.call "doEndTurnAction", myself()


Template.sidebar.events "click button.action-button": (e) ->
  selectedObj = Session.get "selectedObj"

  cardId = selectedObj._id                    # sure-gamble-1
  action = e.target.dataset.action            # draw9Credits
  target = e.target.dataset?.target           # newRemoteServer
  remoteServer = selectedObj.remoteServer     # remoteServer1

  switch action
    ###########
    # SERVERS #
    ###########
    when 'startRun'
      Meteor.call 'doStartRunAction', myself(), target, (err, result) ->
        console.log err if err
    #################
    # CARDS IN HAND #
    #################
    when 'discardFromHand'
      Meteor.call 'doDiscardFromHandAction', myself(), cardId, (err, result) ->
        console.log err if err
    #######
    # ICE #
    #######
    when 'installICE'
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

  Session.set "selectedObj", undefined
