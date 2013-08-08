#-----------------------------------------------------------------------------
# Client-side Global Values
#-----------------------------------------------------------------------------

@CANVAS = 
  width: 1080
  height: 630


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
  String::capitalize = ->
    @charAt(0).toUpperCase() + @slice(1)

  Session.set 'selectedCard', undefined
  Session.set 'showDialog', false
  Session.set 'runnerIsModded', false
  Session.set 'programsAndHardwareInHand', false


  fabric.Canvas::showGameStartImages = (playerObj, game) ->
    @addCardToCanvas playerObj,                     # Runner deck
      {src: 'runner-back.jpg', gameLoc: 'runner'},
      CARD_PARAMS['width']*1.05,
      @height - CARD_PARAMS['height'] - 20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Runner identity
      game["runner"]["identity"],
      CARD_PARAMS['width'] * 2 * 1.05,
      @height - CARD_PARAMS['height'] - 20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp deck
      {src: 'corp-back.jpg', gameLoc: 'corp'},
      @width - CARD_PARAMS['width']*2*1.05,
      20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp identity
      game['corp']['identity'],
      @width - CARD_PARAMS['width']*3*1.05,
      20,
      (true if playerObj.side is 'corp')


  # Created from the perspective of the Runner
  fabric.Canvas::showGameStartText = (playerObj) ->
    @addLocationText playerObj,
      "|--------------     Corp's Hand     --------------|",
      @width - CARD_PARAMS['width']*4.5*1.05,
      8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|--  Corp's Deck  --|",
      @width - CARD_PARAMS['width']*1.5*1.05,
      8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|-- Corp's Discard --|",
      @width - CARD_PARAMS['width']*.5,
      8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|--------------    Runner's Hand    --------------|",
      CARD_PARAMS['width']*4.5*1.05,
      @height - 8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|-  Runner's Deck  -|",
      CARD_PARAMS['width']*1.5*1.05,
      @height - 8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Runner's Discard -|",
      CARD_PARAMS['width']*.5,
      @height - 8,
      (true if playerObj.side is 'corp')


  fabric.Canvas::addCountersToCard = (playerObj, card, cardX, cardY) ->
    x = cardX + CARD_PARAMS['width'] / 2
    y = cardY + CARD_PARAMS['height'] + 6
    
    if playerObj.side == "corp"
      p = new fabric.Point CANVAS['width'] - x, CANVAS['height'] - y
    else
      p = new fabric.Point x, y

    textAttributes =
      fontSize: 12
      selectable: false

    text = new fabric.Text card.counters + '●', textAttributes

    text.setPositionByOrigin p
    @add text


  fabric.Canvas::addLocationText = (playerObj, text, x, y, xyFlip) ->
    textAttributes =
      fontSize: 10
      selectable: true

    textObj = new fabric.Text text, textAttributes

    [x, y] = [@width - x, @height - y] if xyFlip
    p = new fabric.Point(x, y)

    textObj.setPositionByOrigin p, 'center', 'center'
    @add textObj


  fabric.Canvas::displayPlayerHands = (result) ->
    # result = { ownHand: [Card, Card], opponentHandSize: 3 }
    playerObj = myself()

    @displayOwnHand playerObj, result['ownHand']
    @displayOpponentHand playerObj, result['opponentHandSize']


  fabric.Canvas::addCardToCanvas = (playerObj, card, x, y, xyFlip) ->
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


  fabric.Canvas::displayOwnHand = (playerObj, hand) ->
    i = 0
    while i < hand.length
      card = hand[i]

      y = @height - CARD_PARAMS['height'] - 20                        # Bottom row 
      x = CARD_PARAMS['width']*3*1.05 + i*CARD_PARAMS['width']*0.4    # Start in 3rd column and overlap
        
      @addCardToCanvas playerObj, card, x, y
      
      i++


  fabric.Canvas::displayOpponentHand = (playerObj, handSize) ->
    card = {}
    if playerObj.side is 'runner'
      card['gameLoc'] = 'corp.hand'
      card['src'] = 'corp-back.jpg'
    else if playerObj.side is 'corp'
      card['gameLoc'] = 'runner.hand'
      card['src'] = 'runner-back.jpg'

    i = 0
    while i < handSize
      y = 0 + 20
      x = (@width - CARD_PARAMS['width']*4*1.05) - i*CARD_PARAMS['width']*0.4

      @addCardToCanvas playerObj, card, x, y
      i++


  fabric.Canvas::displayRunnerResources = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length
      y = CANVAS['height'] - CARD_PARAMS['height'] * 2 - 15   # 2nd row from bottom with room for counters
      x = CARD_PARAMS['width'] * 2 + i * CARD_PARAMS['width'] # Start in 2nd column
      resource = result[i]

      xyFlip = true if playerObj.side is 'corp'
      @addCardToCanvas playerObj, resource, x, y, xyFlip

      if resource.counters
        @addCountersToCard playerObj, resource, x, y
      i++


  fabric.Canvas::displayRunnerHardware = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length                                   # Iterate through installed hardware
      hardware = result[i]
      y = CANVAS['height'] - CARD_PARAMS['height'] * 3 - 30   # 3rd row from bottom with room for counters
      x = CARD_PARAMS['width'] * 2 + i * CARD_PARAMS['width'] # 2nd column

      xyFlip = true if playerObj.side is 'corp'               # Flip on x/y axis if player is the runner
      @addCardToCanvas playerObj, hardware, x, y, xyFlip

      if hardware.counters
        @addCountersToCard playerObj, hardware, x, y
      i++


  # TODO: Handle server without asset/agenda
  fabric.Canvas::displayRemoteServers = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length                                     # Iterate through the remote servers
      server = result[i]
      card = server['assetsAndAgendas'][0]                      # Get the installed asset or agenda

      y = @height - CARD_PARAMS['height'] - 20                  # Bottom row with room for server name, counters
      x = CARD_PARAMS['width']*6 + i*CARD_PARAMS['width']*1.2   # Just to the right of Corp's hand

      xyFlip = true if playerObj.side is 'runner'               # Flip on x/y axis if player is the runner
      @addCardToCanvas playerObj, card, x, y, xyFlip
      @addLocationText playerObj, "|-- #{server.name} --|", x+45, @height-8, xyFlip
      @addCountersToCard playerObj, card, x, y if card.counters
      i++
