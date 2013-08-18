Template.actionChoices.playerSide = ->
  myself().side

Template.actionChoices.onlyOneObject = () ->
  if Session.get("selectedObj") && (Session.get("selectedObj") != undefined)
    cardMetadata = Session.get "selectedObj"
  else
    false

Template.actionChoices.actions = () ->
  if Template.actionChoices.onlyOneObject
    me = myself()
    obj = Session.get("selectedObj")

    ###########
    # SERVERS #
    ###########
    if obj.owner is 'corp' and obj.type is 'server' and me.side is 'runner'
      
      # Corp's Hand server
      if obj._id is 'corpHand'
        return [
          action: 'startRun'
          actionText: "Begin a run on the Corp's hand",
          _id: obj._id
        ]

      # Corp's Deck server
      if obj._id is 'corpDeck'
        return [
          action: 'startRun'
          actionText: "Begin a run on the Corp's deck",
          _id: obj._id
        ]

      # Corp's Discard server
      if obj._id is 'corpDiscard'
        return [
          action: 'startRun'
          actionText: "Begin a run on the Corp's deck",
          _id: obj._id
        ]

      # Other this is a remote server
      else
        return [
          action: 'startRun'
          actionText: "Begin a run on #{obj.name}",
          _id: obj._id
        ]

    ###########
    #   ICE   #
    ###########
    if obj.cardType is 'ICE'

      # Installed but unrezzed ICE
      if obj.loc is 'remoteServer' and obj.rezzed is false
        return obj.unrezzedActions

      # Uninstalled ICE
      if obj.loc is 'hand'
        Meteor.call 'getRemoteServers', myself(), (err, result) ->
          console.log err if err
          Session.set 'remoteServers', result
        arr = _.toArray(Session.get('remoteServers'))
        opts = _.map arr, (obj) ->
          action: "installICE"
          actionText: "Install to " + obj.name
          _id: obj._id
        opts.push
          action: "installICE"
          actionText: "Install to new remote server"
          _id: "newServer"
        opts.push
          action: 'discardFromHand'
          actionText: 'Discard this card'
        return opts

    ##########
    # ASSETS #
    ##########
    if obj.cardType is 'Asset'

      # Installed but unrezzed Assets
      if obj.loc is 'remoteServer' and obj.rezzed is false
        return obj.unrezzedActions

      # Uninstalled Assets
      if obj.loc is 'hand'
        Meteor.call 'getRemoteServers', myself(), (err, result) ->
          console.log err if err
          Session.set 'remoteServers', result
        arr = _.toArray(Session.get('remoteServers'))
        opts = _.map arr, (obj) ->
          action: "installAsset"
          actionText: "Install to " + obj.name
          _id: obj._id
        opts.push
          action: "installAsset"
          actionText: "Install to new remote server"
          _id: "newServer"
        opts.push
          action: 'discardFromHand'
          actionText: 'Discard this card'
        return opts

    ############################################
    # RESOURCES & HARDWARE & EVENT & OPERATION #
    ############################################
    if obj.cardType in ['Resource', 'Hardware', 'Event', 'Operation']

      # Installed Resources
      if obj.loc in ['resources', 'hardware']
        return obj.boardActions

      # Uninstalled Resources
      if obj.loc is 'hand'
        opts = obj.handActions
        opts.push
          action: 'discardFromHand'
          actionText: 'Discard this card'
        return opts

  else
    return []


Template.actionChoices.cardName = () ->
  if Template.actionChoices.onlyOneObject
    actions = Session.get("selectedObj")['name']
  else
    ""

Template.actionChoices.cardDescription = () ->
  if Template.actionChoices.onlyOneObject
    actions = Session.get("selectedObj")['description']
  else
    ""
