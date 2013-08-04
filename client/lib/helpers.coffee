#-----------------------------------------------------------------------------
# Client-side Global Values
#-----------------------------------------------------------------------------

@CANVAS = 
  width: 1080
  height: 600


@CARD_PARAMS =
  hasControls: false
  hasRotatingPoint: false
  lockMovementX: true
  lockMovementY: true
  width: 90
  height: 127


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
  add_card_to_canvas cvs,
                     playerObj,
                     game["runner"]["cardBack"],
                     CARD_PARAMS['width'],
                     CANVAS['height'] - CARD_PARAMS['height']

  add_card_to_canvas cvs,
                     playerObj,
                     game["runner"]["identity"],
                     CARD_PARAMS['width'] * 2,
                     CANVAS['height'] - CARD_PARAMS['height']
  
  # Then add cards for corp
  add_card_to_canvas cvs,
                     playerObj,
                     game['corp']['cardBack'],
                     CANVAS['width'] - CARD_PARAMS['width'] * 2
                     0


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
  Session.set 'selectedCard', undefined
  Session.set 'showDialog', false
  Session.set 'runnerIsModded', false
  Session.set 'programsAndHardwareInHand', false


  fabric.Canvas.prototype.addCountersToCard = (playerObj, card, cardX, cardY) ->
    x = cardX + CARD_PARAMS['width'] / 2
    y = cardY + CARD_PARAMS['height'] + 6
    
    if playerObj.side == "corp"
      p = new fabric.Point CANVAS['width'] - x, CANVAS['height'] - y
    else
      p = new fabric.Point x, y

    textAttributes =
      fontSize: 14
      selectable: false

    text = new fabric.Text card.counters + '●', textAttributes

    text.setPositionByOrigin p
    textObj = @.add text


  fabric.Canvas.prototype.displayPlayerHands = (result) ->
    # result = { ownHand: [Card, Card], opponentHandSize: 3 }
    playerObj = myself()

    @displayOwnHand playerObj, result['ownHand']
    @displayOpponentHand playerObj, result['opponentHandSize']


  fabric.Canvas.prototype.addCardToCanvas = (playerObj, card, x, y, xyFlip) ->
    x = x + CARD_PARAMS['width'] / 2
    y = y + CARD_PARAMS['height'] / 2
    p = new fabric.Point(x, y)

    fabric.Image.fromURL card["src"], (oImg) =>
      oImg.set CARD_PARAMS
      oImg.set "isCard", true
      oImg.set "metadata", card

      if playerObj.side != card['gameLoc'].split(".")[0]
        oImg.set "flipY", true

      p = new fabric.Point(@width - x, @height - y) if xyFlip

      oImg.setPositionByOrigin (p)
      @add oImg


  fabric.Canvas.prototype.displayOwnHand = (playerObj, hand) ->
    i = 0
    while i < hand.length
      y = @height - CARD_PARAMS['height'] # Add to bottom row
      x = CARD_PARAMS['width'] * 3 + i * CARD_PARAMS['width'] * 0.7 # Start in 3rd column and overlap a bit
      card = hand[i]
        
      @addCardToCanvas playerObj, card, x, y
      i++


  fabric.Canvas.prototype.displayOpponentHand = (playerObj, handSize) ->
    card = {}
    if playerObj.side is 'runner'
      card['gameLoc'] = 'corp.hand'
      card['src'] = 'corp-back.jpg'
    else if playerObj.side is 'corp'
      card['gameLoc'] = 'runner.hand'
      card['src'] = 'runner-back.jpg'

    i = 0
    while i < handSize
      y = 0
      x = (CANVAS['width'] - CARD_PARAMS['width'] * 4) - i * CARD_PARAMS['width'] * 0.7

      @addCardToCanvas playerObj, card, x, y
      i++


  fabric.Canvas.prototype.displayRunnerResources = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length
      y = CANVAS['height'] - CARD_PARAMS['height'] * 2 - 15 # Add to 2nd to bottom row with room for counters
      x = CARD_PARAMS['width'] * 2 + i * CARD_PARAMS['width'] # Start in 2nd column
      resource = result[i]

      xyFlip = true if playerObj.side is 'corp'
      @addCardToCanvas playerObj, resource, x, y, xyFlip

      if resource.counters
        @addCountersToCard playerObj, resource, x, y
      i++


  fabric.Canvas.prototype.displayRunnerHardware = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length
      y = CANVAS['height'] - CARD_PARAMS['height'] * 3 - 30 # Add to 2nd to bottom row with room for counters
      x = CARD_PARAMS['width'] * 2 + i * CARD_PARAMS['width'] # Start in 2nd column
      hardware = result[i]

      xyFlip = true if playerObj.side is 'corp'

      hardware['gameLoc'] = 'runner.hardware'
      @addCardToCanvas playerObj, hardware, x, y, xyFlip

      if hardware.counters
        @addCountersToCard playerObj, hardware, x, y
      i++
