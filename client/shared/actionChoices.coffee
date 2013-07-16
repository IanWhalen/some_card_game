Template.actionChoices.playerSide = ->
  myself().side

Template.actionChoices.oneCardIsSelected = () ->
  try
    Session.get "selectedCard"
  catch e
    false
