#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------

Template.main_canvas.rendered = ->
  main_canvas = new fabric.Canvas("main_canvas")
  main_canvas.hoverCursor = "pointer"
  add_hover_helper main_canvas

  show_game_start_images main_canvas, myself(), game()
  
  main_canvas.on "object:over", (e) ->
    $("img#magnifier").attr "src", e.target._element.attributes.src.value

  main_canvas.on "object:out", (e) ->
    $("img#magnifier").attr "src", "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="

  main_canvas.on "object:selected", (e) ->
    if !main_canvas._activeGroup && main_canvas._activeObject
      Session.set "selectedCard", e.target.metadata

  main_canvas.on "selection:cleared", (e) ->
    Session.set "selectedCard", undefined


  # Refresh display every time either player's hand is changed
  Meteor.call "getPlayersHands", myself(), (err, result) ->
    console.log err if err
    main_canvas.displayPlayerHands result


  # Refresh display every time either player's discard pile is changed
  Meteor.call "getTopOfDiscardPiles", myself(), (err, result) ->
    console.log err if err
    
    playerObj = myself()

    runnerDiscardTop = result['runner']
    if runnerDiscardTop
      runnerX = 0
      runnerY = CANVAS['height'] - CARD_PARAMS['height']
      runnerDiscardTop['gameLoc'] = 'runner.discard'
      add_card_to_canvas main_canvas, playerObj, runnerDiscardTop, runnerX, runnerY

    corpDiscardTop = result['corp']
    if corpDiscardTop
      corpX = CANVAS['width'] - CARD_PARAMS['width']
      corpY = 0
      corpDiscardTop['gameLoc'] = 'corp.discard'
      add_card_to_canvas main_canvas, playerObj, corpDiscardTop, corpX, corpY


  # Refresh display every time the Runner's in-play resources change
  Meteor.call "getRunnerResources", myself(), (err, result) ->
    console.log err if err
    main_canvas.displayRunnerResources result


  # Refresh display every time the Runner's in-play hardware change
  Meteor.call "getRunnerHardware", myself(), (err, result) ->
    console.log err if err

    playerObj = myself()

    i = 0
    while i < result.length
      y = CANVAS['height'] - CARD_PARAMS['height'] * 3 - 30 # Add to 2nd to bottom row with room for counters
      x = CARD_PARAMS['width'] * 2 + i * CARD_PARAMS['width'] # Start in 2nd column
      hardware = result[i]

      hardware['gameLoc'] = 'runner.hardware'
      add_card_to_canvas main_canvas, playerObj, hardware, x, y

      if hardware.counters
        main_canvas.addCountersToCard playerObj, hardware, x, y
      i++


Template.main_canvas.canvasHeight = () ->
  CANVAS['height']


Template.main_canvas.canvasWidth = () ->
  CANVAS['width']


#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
