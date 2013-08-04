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
    
    if cardObj['cardType'] is 'Asset'
      Meteor.call 'getRemoteServers', myself(), (err, result) ->
        console.log err if err
        Session.set 'remoteServers', result

      opts = _.toArray(Session.get('remoteServers'))
      opts.push {action: 'installAssetToNewRemoteServer', actionText: 'Install to new remote server'}
      return opts

    if cardObj['gameLoc'] in ['runner.hand', 'corp.hand']
      return cardObj['handActions']
    
    if cardObj['gameLoc'] is 'runner.resources'
      return cardObj['boardActions']
  
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
