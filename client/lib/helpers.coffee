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
      @width - (CARD_PARAMS['width'] + CARD_PARAMS['width']*1.05),
      20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp identity
      game['corp']['identity'],
      @width - (CARD_PARAMS['width'] + CARD_PARAMS['width']*2*1.05),
      20,
      (true if playerObj.side is 'corp')


  # Created from the perspective of the Runner
  fabric.Canvas::showGameStartText = (playerObj) ->

    ########
    # CORP #
    ########
    @addLocationText playerObj,
      "|-------                Hand                -------|",
      @width - CARD_PARAMS['width']*3*1.05 - 160,
      8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,           
      "|-  Deck  -|",
      @width - CARD_PARAMS['width']*1.5*1.031,
      8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      @width - CARD_PARAMS['width']*.5,
      8,
      (true if playerObj.side is 'corp')

    ##########
    # RUNNER #
    ##########
    @addLocationText playerObj,
      "|-------                Hand                -------|",
      CARD_PARAMS['width']*3*1.05 + 160,
      @height - 8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|-  Deck  -|",
      CARD_PARAMS['width']*1.5*1.031,
      @height - 8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      CARD_PARAMS['width']*.5,
      @height - 8,
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|---------                  Hardware                  ---------|",
      CARD_PARAMS['width']*9,
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
      fontSize: 10
      fontFamily: 'monaco'
      selectable: false

    text = new fabric.Text card.counters + '●', textAttributes

    text.setPositionByOrigin p
    @add text


  fabric.Canvas::addLocationText = (playerObj, text, x, y, xyFlip) ->
    textAttributes =
      fontSize: 10
      fontFamily: 'monaco'
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

      # if playerObj.side != card.owner
      #   oImg.set "flipY", true

      p = new fabric.Point(@width - x, @height - y) if xyFlip

      oImg.setPositionByOrigin (p)
      @add oImg


  fabric.Canvas::addICEToCanvas = (playerObj, card, x, y, xyFlip) ->
    x = x + CARD_PARAMS['width'] / 2
    y = y + CARD_PARAMS['height'] / 2
    p = new fabric.Point(x, y)

    fabric.Image.fromURL card["src"], (oImg) =>
      oImg.set CARD_PARAMS
      oImg.set "isCard", true
      oImg.set "metadata", card
      oImg.set "angle", 90

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
      x = CARD_PARAMS['width']*3*1.05 + i*CARD_PARAMS['width']*0.3    # Start in 3rd column and overlap
        
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
      x = (@width - CARD_PARAMS['width']*4*1.05) - i*CARD_PARAMS['width']*0.3

      @addCardToCanvas playerObj, card, x, y
      i++


  fabric.Canvas::displayRunnerResources = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length
      y = @height - CARD_PARAMS['height']*2 - 40   # 2nd row from bottom with room for counters
      x = i*CARD_PARAMS['width']*1.01
      resource = result[i]

      xyFlip = true if playerObj.side is 'corp'
      @addCardToCanvas playerObj, resource, x, y, xyFlip

      if resource.counters
        @addCountersToCard playerObj, resource, x, y
      i++


  fabric.Canvas::displayRunnerHardware = (result) ->
    playerObj = myself()

    i = 0
    while i < result.length                                    # Iterate through installed hardware
      hardware = result[i]
      y = @height - CARD_PARAMS['height'] - 20
      x = CARD_PARAMS['width']*7 + i*CARD_PARAMS['width']*1.01

      xyFlip = true if playerObj.side is 'corp'                # Flip on x/y axis if player is the runner
      @addCardToCanvas playerObj, hardware, x, y, xyFlip

      if hardware.counters
        @addCountersToCard playerObj, hardware, x, y
      i++


  # TODO: Handle server without asset/agenda
  fabric.Canvas::displayRemoteServers = (result) ->
    playerObj = myself()

    for server, i in result
      do (server, i) =>
        card = server['assetsAndAgendas'][0]                      # Get the installed asset or agenda
        if card
          y = @height - CARD_PARAMS['height'] - 20                  # Bottom row with room for server name, counters
          x = CARD_PARAMS['width']*7 + i*CARD_PARAMS['width']*1.4   # Just to the right of Corp's hand

          xyFlip = true if playerObj.side is 'runner'               # Flip on x/y axis if player is the runner
          @addCardToCanvas playerObj, card, x, y, xyFlip
          @addCountersToCard playerObj, card, x, y if card.counters

        for ice, j in server['ICE']
          do (ice, j) =>
            y = @height - CARD_PARAMS['height']*2 - CARD_PARAMS['width']*(j)
            x = CARD_PARAMS['width']*7 + i*CARD_PARAMS['width']*1.4

            xyFlip = true if playerObj.side is 'runner'
            @addICEToCanvas playerObj, ice, x, y, xyFlip

        if card or server['ICE'].length
          @addLocationText playerObj, "|-  #{server.name}  -|", x+45, @height-8, xyFlip


  fabric.Canvas::displayDiscardPiles = (result) ->
    playerObj = myself()

    if result.runner
      @addCardToCanvas playerObj,                     # Runner deck
        result.runner,
        0,
        @height - CARD_PARAMS['height'] - 20,
        (true if playerObj.side is 'corp')

    if result.corp
      @addCardToCanvas playerObj,                     # Corp deck
        result.corp,
        @width - CARD_PARAMS['width'],
        0,
        (true if playerObj.side is 'corp')
