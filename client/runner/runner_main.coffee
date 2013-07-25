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

  Meteor.call "getPlayersHands", game(), myself(), (err, result) ->
    # Array of runner hand then corp hand
    console.log err if err

    gameObj = game()
    playerObj = myself()

    runnerHand = result[0]
    i = 0
    while i < runnerHand.length
      y = 510 # Add to bottom row
      x = 135*3+i*100  # Start in 3rd column and overlap a bit
      runnerCard = runnerHand[i]

      if playerObj.side == 'corp'
        runnerCard = gameObj['runner']['cardBack']
        
      runnerCard['gameLoc'] = 'runner.hand'
      add_card_to_canvas main_canvas, playerObj, runnerCard, x, y
      i++

    corpHand = result[1]
    i = 0
    while i < corpHand.length
      y = 0
      x = (1100-135*3) - i*100
      corpCard = corpHand[i]

      if playerObj.side == 'runner'
        runnerCard = gameObj['corp']['cardBack']

      corpCard['gameLoc'] = 'corp.hand'
      add_card_to_canvas main_canvas, playerObj, corpCard, x, y
      i++


  Meteor.call "getTopOfDiscardPiles", myself(), (err, result) ->
    console.log err if err
    
    playerObj = myself()

    runnerDiscardTop = result['runner']
    if runnerDiscardTop
      runnerX = 0
      runnerY = 510
      runnerDiscardTop['gameLoc'] = 'runner.discard'
      add_card_to_canvas main_canvas, playerObj, runnerDiscardTop, runnerX, runnerY

    corpDiscardTop = result['corp']
    if corpDiscardTop
      corpX = 1100-135
      corpY = 0
      corpDiscardTop['gameLoc'] = 'corp.discard'
      add_card_to_canvas main_canvas, playerObj, corpDiscardTop, corpX, corpY


#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
