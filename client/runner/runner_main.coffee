#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------

Template.main_canvas.rendered = ->
  main_canvas = new fabric.Canvas("main_canvas")
  main_canvas.hoverCursor = "pointer"
  add_hover_helper main_canvas

  show_game_start_images main_canvas, game()
  
  main_canvas.on "object:over", (e) ->
    $("img#magnifier").attr "src", e.target._element.attributes.src.value

  main_canvas.on "object:out", (e) ->
    $("img#magnifier").attr "src", "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="

  main_canvas.on "object:selected", (e) ->
    if !main_canvas._activeGroup && main_canvas._activeObject
      Session.set "selectedCard", e.target.metadata

  main_canvas.on "selection:cleared", (e) ->
    Session.set "selectedCard", undefined

  Meteor.call "get_hands", game(), myself(), (err, result) ->
    console.log err if err
    mySide = myself().side
    oppSide = getOppSide mySide

    myHand = result[0]
    i = 0
    while i < myHand.length
      y = 510 # Add to bottom row
      x = 135*3+i*100  # Start in 3rd column and overlap a bit
      myCard = myHand[i]
      myCard['gameLoc'] = mySide + ".hand"

      add_card_to_canvas main_canvas, myCard, x, y
      i++

    oppHandLength = result[1]
    if oppHandLength > 0
      oppCard = getOppCard mySide
      i = 0
      while i < oppHandLength
        y = 510 # Add to bottom row
        x = 135*3+i*100 # Start in 3rd column and overlap a bit
        oppCard['gameLoc'] = oppSide + ".hand"

        add_card_to_canvas main_canvas, oppCard, x, y
        i++

  Meteor.call "getTopOfDiscardPiles", myself(), (err, result) ->
    # { corp: cardObj1, runner: cardObj2 }
    console.log err if err
    mySide = myself().side
    oppSide = getOppSide mySide

    if result[mySide]
      x = 0
      y = 510
      myCard = result[mySide]
      myCard['gameLoc'] = mySide + ".discard"
      add_card_to_canvas main_canvas, myCard, x, y

    if result[oppSide]
      x = 0
      y = 510
      oppCard = result[oppSide]
      oppCard['gameLoc'] = oppSide + ".discard"
      add_card_to_canvas main_canvas, oppCard, x, y

#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
