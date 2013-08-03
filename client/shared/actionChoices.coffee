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
