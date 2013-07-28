Template.history.logLines = ->
  gameObj = game()
  me = myself()

  if gameObj[me.side]['logs']
    logs = gameObj[me.side]['logs']
  else
    logs = []
  
  logs

  # if text != undefined
  #   $('#history').append('<p>' + text + '</p>')

Template.history.rendered = ->
  $("#history").scrollTop($("#history")[0].scrollHeight);