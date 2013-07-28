class @Game
  constructor: (obj) ->
    for key, value of obj
      @[key] = value
  

  #-----------------------------------------------------------------------------
  # DATABASE FUNCTIONS
  #
  #-----------------------------------------------------------------------------

  setCurrentPlayerField: (playerId) ->
    Games.update(@._id, {$set: { current_player : playerId}});