#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------

Template.main_canvas.rendered = ->
  main_canvas = new fabric.Canvas("main_canvas")
  main_canvas.hoverCursor = "pointer"
  add_hover_helper main_canvas

  show_game_start_images main_canvas, game()
  
  # now we can observe "object:over" and "object:out" events
  main_canvas.on "object:over", (e) ->
    $("img#magnifier").attr "src", e.target._element.attributes.src.value

  main_canvas.on "object:out", (e) ->
    $("img#magnifier").attr "src", "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="

  main_canvas.on "object:selected", (e) ->
    selectedObjArr = []

    for c in [main_canvas, hand_canvas]
      if !c._activeGroup && c._activeObject
        selectedObjArr.push c._activeObject
    
    if selectedObjArr.length == 1
      Session.set "selectedCard", e.target.actions

  main_canvas.on "selection:cleared", (e) ->
    Session.set "selectedCard", undefined

#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
