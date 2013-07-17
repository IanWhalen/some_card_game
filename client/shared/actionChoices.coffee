Template.actionChoices.playerSide = ->
  myself().side

Template.actionChoices.onlyOneCard = () ->
  if Session.get("selectedCard") && (Session.get("selectedCard") != undefined)
    cardMetadata = Session.get "selectedCard"
  else
    false

Template.actionChoices.actions = () ->
  if Template.actionChoices.onlyOneCard
    actions = Session.get("selectedCard")['actions']
  else
    []

Template.actionChoices.cardName = () ->
  if Template.actionChoices.onlyOneCard
    actions = Session.get("selectedCard")['name']
  else
    ""
