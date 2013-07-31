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
      actions = cardObj['handActions']
    
    if cardObj['gameLoc'] == 'runner.resources'
      actions = cardObj['boardActions']
  
  else
    actions = []
  
  actions

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
