fabric.NetrunnerCanvas = fabric.util.createClass(fabric.Canvas,
  type: "netrunnerCanvas"

  initialize: (el, options) ->
    opt = options or (options = {})
    @callSuper "initialize", el, opt

    @cardHeight = 127
    @cardWidth = 90

  #-----------------------------------------------------------------------------
  # ADD OBJECTS TO CANVAS
  #-----------------------------------------------------------------------------
  addCardToCanvas: (playerObj, card, x, y, xyFlip) ->
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
    p = new fabric.Point x, y

    textObj.set 'metadata', metadata
    textObj.setPositionByOrigin p, 'center', 'center'
    @add textObj


  addCountersToCard: (playerObj, card, cardX, cardY) ->
    x = cardX
    y = cardY + @cardHeight * .5 + 8
    
    if playerObj.side is 'corp'
      p = new fabric.Point @width - x, @height - y
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
    if playerObj.side is 'runner'
      fabric.Image.fromURL card["src"], (oImg) =>
        count = _.filter(@_objects, (obj) ->
          obj.metadata.owner is playerObj.side and obj.metadata.loc is 'hand'
        ).length
        oImg.set CARD_PARAMS
        oImg.set "isCard", true
        oImg.set "metadata", card
        if playerObj.side != card.owner
          oImg.set "flipY", true
        x = 20 + @cardWidth * 3 + @cardWidth * .5 + count * @cardWidth * 0.25
        y = @height - 20 - @cardHeight * .5
        p = new fabric.Point(x, y)
        oImg.setPositionByOrigin (p)
        @add oImg

    if playerObj.side is 'corp'
      fabric.Image.fromURL card["src"], (oImg) =>
        count = _.filter(@_objects, (obj) ->
          obj.metadata.owner is playerObj.side and obj.metadata.loc is 'hand'
        ).length
        oImg.set CARD_PARAMS
        oImg.set "isCard", true
        oImg.set "metadata", card
        if playerObj.side != card.owner
          oImg.set "flipY", true
        x = 20 + @cardHeight * 2 + @cardWidth * 1.5 + count * @cardWidth * 0.25
        y = @height - 20 - @cardHeight * .5
        p = new fabric.Point(x, y)
        oImg.setPositionByOrigin (p)
        @add oImg

  addICEToCanvas: (playerObj, card, x, y, xyFlip) ->
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
      "|-------             Hand             -------|",
      @width - 20 - @cardHeight * 2 - @cardWidth * 2.5,
      10,
      {_id: 'corpHand', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,           
      "|-  Deck  -|",
      @width - (10 + @cardHeight * 1.5),
      8,
      {_id: 'corpDeck', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      @width - (5 + @cardHeight * .5),
      8,
      {_id: 'corpDiscard', owner: 'corp', type: 'server'},
      (true if playerObj.side is 'corp')

    ##########
    # RUNNER #
    ##########
    @addLocationText playerObj,
      "|-------             Hand             -------|",
      20 + @cardWidth * 4.5,
      @height - 10,
      {},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|-  Deck  -|",
      10 + @cardWidth * 1.5,
      @height - 10,
      {},
      (true if playerObj.side is 'corp')

    @addLocationText playerObj,
      "|- Discard -|",
      5 + @cardWidth * .5,
      @height - 10,
      {},
      (true if playerObj.side is 'corp')


  showGameStartImages: (playerObj, game) ->
    @addCardToCanvas playerObj,                     # Runner deck
      {src: 'runner-back.jpg', owner: 'runner'},
      10 + @cardWidth * 1.5,
      @height - 20 - @cardHeight / 2,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Runner identity
      game["runner"]["identity"],
      15 + @cardWidth * 2.5,
      @height - 20 - @cardHeight / 2,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp deck
      {src: 'corp-back.jpg', owner: 'runner'},
      @width - (10 + @cardHeight * 1.5),
      20 + @cardHeight / 2,
      (true if playerObj.side is 'corp')

    @addCardToCanvas playerObj,                     # Corp identity
      game['corp']['identity'],
      @width - (15 + @cardHeight * 2 + @cardWidth * .5),
      20 + @cardHeight / 2,
      (true if playerObj.side is 'corp')

  #-----------------------------------------------------------------------------
  # DECLARE VARIABLE OBJECTS TO BE ADDED TO CANVAS
  #-----------------------------------------------------------------------------

  displayDiscardPiles: (result) ->
    playerObj = myself()

    if result.runner
      @addCardToCanvas playerObj,
        result.runner,
        5 + @cardWidth * .5,
        @height - 20 - @cardHeight * .5,
        (true if playerObj.side is 'corp')

    if result.corp
      @addCardToCanvas playerObj,
        result.corp,
        @width - (5 + @cardHeight * .5),
        20 + @cardHeight * .5,
        (true if playerObj.side is 'corp')


  # TODO: Handle server without asset/agenda
  displayRemoteServers: (result) ->
    playerObj = myself()

    for server, i in result
      do (server, i) =>
        card = server['assetsAndAgendas'][0]                        # Get the installed asset or agenda
        if card
          y = @height - 20 - @cardHeight * .5                       # Bottom row with room for server name, counters
          x = @cardWidth*7.5 + @cardHeight * .5 + @cardHeight * i   # Just to the right of Corp's hand

          xyFlip = true if playerObj.side is 'runner'               # Flip on x/y axis if player is the runner
          @addCardToCanvas playerObj, card, x, y, xyFlip
          @addCountersToCard playerObj, card, x, y if card.counters

        for ice, j in server['ICE']
          do (ice, j) =>
            y = @height - 20 - @cardHeight - @cardWidth * .5 - @cardWidth * j

            xyFlip = true if playerObj.side is 'runner'
            @addICEToCanvas playerObj, ice, x, y, xyFlip

        if card or server['ICE'].length
          metadata =
            _id: server._id
            owner: 'corp'
            type: 'server'
            name: server.name

          @addLocationText playerObj, "|-  #{server.name}  -|", x, @height - 10, metadata, xyFlip


  displayRunnerResources: (result) ->
    playerObj = myself()

    i = 0
    while i < result.length
      y = @height - 40 - @cardHeight * 1.5
      x = 5 + @cardWidth * .5 + i * (@cardWidth + 5)
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
      y = @height - @cardHeight - 20
      x = @cardWidth*7 + i*@cardWidth*1.01

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
      i = 0
      while i < handSize
        y = 20 + @cardHeight * .5
        x = @width - (20 + @cardHeight * 2 + @cardWidth*1.5 + i * @cardWidth * .3)
        @addCardToCanvas playerObj, card, x, y
        i++
    
    if playerObj.side is 'corp'
      card =
        src: 'runner-back.jpg'
        owner: 'runner'
      i = 0
      while i < handSize
        y = 20 + @cardHeight * .5
        x = @width - (20 + @cardWidth * 3.5 + i * @cardWidth * .3)
        @addCardToCanvas playerObj, card, x, y
        i++


  displayPlayerHands: (result) ->
    # result = { ownHand: [Card, Card], opponentHandSize: 3 }
    playerObj = myself()

    @displayOwnHand playerObj, result['ownHand']
    @displayOpponentHand playerObj, result['opponentHandSize']


  displayDeckICE: (installedICE) ->
    playerObj = myself()

    for ice, i in installedICE
      do (ice, i) =>
        y = 20 + @cardHeight + 5 + @cardWidth * .5 + @cardWidth * i
        x = @width - (10 + @cardHeight * 1.5)


        xyFlip = true if playerObj.side is 'corp'
        @addICEToCanvas playerObj, ice, x, y, xyFlip
)
