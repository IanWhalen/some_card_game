fabric.NetrunnerCanvas = fabric.util.createClass(fabric.Canvas,
  type: "netrunnerCanvas"

  initialize: (el, options) ->
    opt = options or (options = {})
    @callSuper "initialize", el, opt


  #-----------------------------------------------------------------------------
  # ADD OBJECTS TO CANVAS
  #-----------------------------------------------------------------------------
  addCardToCanvas: (playerObj, card, x, y, xyFlip) ->
    x = x + CARD_PARAMS['width'] / 2
    y = y + CARD_PARAMS['height'] / 2
    p = new fabric.Point(x, y)

    fabric.Image.fromURL card["src"], (oImg) =>
      oImg.set CARD_PARAMS
      oImg.set "isCard", true
      oImg.set "metadata", card

      if playerObj.side != card.owner
        oImg.set "flipY", true

      p = new fabric.Point(@width - x, @height - y) if xyFlip

      oImg.setPositionByOrigin (p)
      @add oImg


  addLocationText: (playerObj, text, x, y, metadata, xyFlip) ->
    textAttributes =
      fontSize: 10
      fontFamily: 'monaco'
      hasControls: false
      hasRotatingPoint: false
      lockMovementX: true
      lockMovementY: true

    textObj = new fabric.Text text, textAttributes

    [x, y] = [@width - x, @height - y] if xyFlip
    p = new fabric.Point(x, y)

    textObj.set 'metadata', metadata
    textObj.setPositionByOrigin p, 'center', 'center'
    @add textObj


  addCountersToCard: (playerObj, card, cardX, cardY) ->
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


  addOwnHandCardToCanvas: (playerObj, card) ->
    fabric.Image.fromURL card["src"], (oImg) =>
      count = _.filter(@_objects, (obj) ->
        obj.metadata.owner is playerObj.side and obj.metadata.loc is 'hand'
      ).length
      oImg.set CARD_PARAMS
      oImg.set "isCard", true
      oImg.set "metadata", card
      if playerObj.side != card.owner
        oImg.set "flipY", true
      x = (CARD_PARAMS['width']*3*1.05 + count*CARD_PARAMS['width']*0.3) + (CARD_PARAMS['width'] / 2)
      y = (@height - CARD_PARAMS['height'] - 20) + CARD_PARAMS['height'] / 2
      p = new fabric.Point(x, y)
      oImg.setPositionByOrigin (p)
      @add oImg


  addICEToCanvas: (playerObj, card, x, y, xyFlip) ->
    x = x + CARD_PARAMS['width'] / 2
    y = y + CARD_PARAMS['height'] / 2
    p = new fabric.Point(x, y)

    fabric.Image.fromURL card["src"], (oImg) =>
      oImg.set CARD_PARAMS
      oImg.set "isCard", true
      oImg.set "metadata", card

      if card.cardType is 'ICE'
        if playerObj.side != card.owner
          oImg.set 'angle', 270
        else
          oImg.set 'angle', 90

      p = new fabric.Point(@width - x, @height - y) if xyFlip

      oImg.setPositionByOrigin (p)
      @add oImg


  #-----------------------------------------------------------------------------
  # DECLARE PERMANENT OBJECTS TO BE ADDED TO CANVAS
  #-----------------------------------------------------------------------------
  showGameStartText: (playerObj) ->
    ########
    # CORP #
    ########
    @addLocationText playerObj,
      "|-------                Hand                -------|",
      @width - CARD_PARAMS['width']*3*1.05 - 160,
      8,
      {_id: 'corpHand', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,           
      "|-  Deck  -|",
      @width - CARD_PARAMS['width']*1.5*1.031,
      8,
      {_id: 'corpDeck', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      @width - CARD_PARAMS['width']*.5,
      8,
      {_id: 'corpDiscard', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    ##########
    # RUNNER #
    ##########
    @addLocationText playerObj,
      "|-------                Hand                -------|",
      CARD_PARAMS['width']*3*1.05 + 160,
      @height - 8,
      {},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|-  Deck  -|",
      CARD_PARAMS['width']*1.5*1.031,
      @height - 8,
      {},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      CARD_PARAMS['width']*.5,
      @height - 8,
      {},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|---------                  Hardware                  ---------|",
      CARD_PARAMS['width']*9,
      @height - 8,
      {},
      (true if playerObj.side is 'corp')


  showGameStartImages: (playerObj, game) ->
    @addCardToCanvas playerObj,                     # Runner deck
      {src: 'runner-back.jpg', owner: 'runner'},
      CARD_PARAMS['width']*1.05,
      @height - CARD_PARAMS['height'] - 20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Runner identity
      game["runner"]["identity"],
      CARD_PARAMS['width'] * 2 * 1.05,
      @height - CARD_PARAMS['height'] - 20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp deck
      {src: 'corp-back.jpg', owner: 'runner'},
      @width - (CARD_PARAMS['width'] + CARD_PARAMS['width']*1.05),
      20,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp identity
      game['corp']['identity'],
      @width - (CARD_PARAMS['width'] + CARD_PARAMS['width']*2*1.05),
      20,
      (true if playerObj.side is 'corp')

  #-----------------------------------------------------------------------------
  # DECLARE VARIABLE OBJECTS TO BE ADDED TO CANVAS
  #-----------------------------------------------------------------------------

  displayDiscardPiles: (result) ->
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
        20,
        (true if playerObj.side is 'corp')


  # TODO: Handle server without asset/agenda
  displayRemoteServers: (result) ->
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
          metadata =
            _id: server._id
            owner: 'corp'
            type: 'server'
            name: server.name

          @addLocationText playerObj, "|-  #{server.name}  -|", x+45, @height-8, metadata, xyFlip


  displayRunnerResources: (result) ->
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


  displayRunnerHardware: (result) ->
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


  displayOwnHand: (playerObj, hand) ->
    i = 0
    while i < hand.length
      card = hand[i]
      @addOwnHandCardToCanvas playerObj, card
      i++


  displayOpponentHand: (playerObj, handSize) ->
    if playerObj.side is 'runner'
      card =
        src: 'corp-back.jpg'
        owner: 'corp'
    else if playerObj.side is 'corp'
      card =
        src: 'runner-back.jpg'
        owner: 'runner'

    i = 0
    while i < handSize
      y = 0 + 20
      x = (@width - CARD_PARAMS['width']*4*1.05) - i*CARD_PARAMS['width']*0.3

      @addCardToCanvas playerObj, card, x, y
      i++


  displayPlayerHands: (result) ->
    # result = { ownHand: [Card, Card], opponentHandSize: 3 }
    playerObj = myself()

    @displayOwnHand playerObj, result['ownHand']
    @displayOpponentHand playerObj, result['opponentHandSize']
)