#-----------------------------------------------------------------------------
# Client-side Global Values
#-----------------------------------------------------------------------------

@CARD_PARAMS =
  hasControls: false
  hasRotatingPoint: false
  lockMovementX: true
  lockMovementY: true
  width: 135
  height: 190


#-----------------------------------------------------------------------------
# Client-side Global Functions
#-----------------------------------------------------------------------------

@getOppSide = (side) ->
  if side == "corp"
    "runner"
  else if side == "runner"
    "corp"
  else
    console.log "getOppSide got bad input: " + side

@getOppCard = (side) ->
  opp = getOppSide side
  game()[opp]["cardBack"]


@show_game_start_images = (cvs, playerObj, game) ->
  # First add cards for runner
  add_card_to_canvas cvs, playerObj, game["runner"]["cardBack"], 135, 510
  add_card_to_canvas cvs, playerObj, game["runner"]["identity"], 135*2, 510
  
  # Then add cards for corp
  add_card_to_canvas cvs, playerObj, game['corp']['cardBack'], 1100-135*2, 0


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


@add_card_to_canvas = (cvs, playerObj, card, x, y) ->
  x = x + CARD_PARAMS['width'] / 2
  y = y + CARD_PARAMS['height'] / 2
  p = new fabric.Point(x, y)

  fabric.Image.fromURL card["src"], (oImg) ->
    oImg.set CARD_PARAMS
    oImg.set "isCard", true
    oImg.set "metadata", card

    if playerObj.side != card['gameLoc'].split(".")[0]
      oImg.set "flipY", true

    if playerObj.side == "corp"
      p = new fabric.Point(cvs.width - x, cvs.height - y)

    oImg.setPositionByOrigin (p)
    cvs.add oImg

@add_hover_helper = (canvas) ->
  canvas.findTarget = ((originalFn) ->
    ->
      target = originalFn.apply(this, arguments)
      if target
        canvas.trigger "object:over",
          target: target

        if @_hoveredTarget isnt target
          canvas.trigger "object:over",
            target: target

          if @_hoveredTarget
            canvas.trigger "object:out",
              target: @_hoveredTarget

          @_hoveredTarget = target
      else if @_hoveredTarget
        canvas.trigger "object:out",
          target: @_hoveredTarget

        @_hoveredTarget = null
      else
        canvas.trigger "object:out",
          target: canvas

      target
  )(canvas.findTarget)

#-----------------------------------------------------------------------------
# Startup Functions
#-----------------------------------------------------------------------------

Meteor.startup ->
  Session.set("selectedCard", undefined)
