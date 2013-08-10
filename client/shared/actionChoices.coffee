Template.actionChoices.playerSide = ->
  myself().side

Template.actionChoices.onlyOneCard = () ->
  if Session.get("selectedCard") && (Session.get("selectedCard") != undefined)
    cardMetadata = Session.get "selectedCard"
  else
    false

Template.actionChoices.actions = () ->
  if Template.actionChoices.onlyOneCard
    cardObj = Session.get("selectedCard")
    #######
    # ICE #
    #######
    if cardObj.cardType is 'ICE'
      
      # Uninstalled ICE
      if cardObj.loc is 'hand'
        Meteor.call 'getRemoteServers', myself(), (err, result) ->
          console.log err if err
          Session.set 'remoteServers', result
        opts = _.toArray(Session.get('remoteServers'))
        opts.push
          action: "installICEToNewRemoteServer"
          actionText: "Install to new remote server"
        return opts

    ##########
    # ASSETS #
    ##########
    if cardObj.cardType is 'Asset'

      # Installed but unrezzed Assets
      if cardObj.loc is 'remoteServer' and cardObj.rezzed is false
        return cardObj.unrezzedActions

      # Uninstalled Assets
      if cardObj.loc is 'hand'
        Meteor.call 'getRemoteServers', myself(), (err, result) ->
          console.log err if err
          Session.set 'remoteServers', result
        opts = _.toArray(Session.get('remoteServers'))
        opts.push
          action: "installAssetToNewRemoteServer"
          actionText: "Install to new remote server"
        return opts

    #############
    # RESOURCES #
    #############
    if cardObj.cardType is 'Resource'

      # Installed Resources
      if cardObj.loc is 'resources'
        return cardObj.boardActions

    ###########
    # DEFAULT #
    ###########

    # Cards still in hand
    if cardObj.loc is 'hand'
      return cardObj.handActions
  
  else
    return []


Template.actionChoices.cardName = () ->
  if Template.actionChoices.onlyOneCard
    actions = Session.get("selectedCard")['name']
  else
    ""

Template.actionChoices.cardDescription = () ->
  if Template.actionChoices.onlyOneCard
    actions = Session.get("selectedCard")['description']
  else
    ""
