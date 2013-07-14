#-----------------------------------------------------------------------------
# Client-side Global Values
#-----------------------------------------------------------------------------

@CARD_PARAMS_OBJ =
  hasControls: false
  hasRotatingPoint: false
  originX: "left"
  originY: "top"
  lockMovementX: true
  lockMovementY: true
  width: 135
  height: 190


#-----------------------------------------------------------------------------
# Client-side Global Functions
#-----------------------------------------------------------------------------

@show_game_start_images = (cvs, game) ->
  add_card_to_canvas cvs, game["runner"]["id"]["src"], 140, 510


@myself = ->
  Players.findOne Session.get("player_id")


@set_player_as_ready = ->
  Players.update Session.get("player_id"),
    $set:
      ready: true


@set_player_as_not_ready = ->
  Players.update Session.get("player_id"),
    $set:
      ready: false


@game = ->
  me = myself()
  me and me.game_id and Games.findOne(me.game_id)


@add_card_to_canvas = (cvs, src, x, y) ->
  fabric.Image.fromURL src, (oImg) ->
    oImg.set CARD_PARAMS_OBJ
    oImg.set "left", x
    oImg.set "top", y
    oImg.setCoords()
    
    cvs.add oImg


#-----------------------------------------------------------------------------
# Startup Functions
#-----------------------------------------------------------------------------

Meteor.startup ->
