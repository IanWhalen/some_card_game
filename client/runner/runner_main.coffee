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
      Session.set "selectedCard", e.target.actions

  main_canvas.on "selection:cleared", (e) ->
    Session.set "selectedCard", undefined

  Meteor.call "get_hands", game(), myself(), (err, result) ->
    console.log err if err
    
    myHand = result[0]
    i = 0
    while i < myHand.length
      y = 510
      x = 135*3+i*100
      myCard = myHand[i]

      add_card_to_canvas main_canvas, myCard, x, y
      i++

    oppHandLength = result[1]
    if oppHandLength > 0
      oppCard = getOppCard myself().side
      i = 0
      while i < oppHandLength
        y = 510
        x = 135*3+i*100

        add_card_to_canvas main_canvas, oppCard, x, y
        i++      

#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
