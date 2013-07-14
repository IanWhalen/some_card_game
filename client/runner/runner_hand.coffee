Template.hand_canvas.rendered = ->
  hand_canvas = new fabric.Canvas("hand_canvas")
  hand_canvas.hoverCursor = 'pointer';
  
  Meteor.call "get_hand", game(), myself(), (err, result) ->
    console.log err if err
    
    hand = result
    i = 0
    while i < hand.length
      top = 0
      left = i*135
      src = hand[i]["src"]
      
      add_card_to_canvas hand_canvas, src, left, top
      i++

  add_hover_helper hand_canvas

  # now we can observe "object:over" and "object:out" events
  hand_canvas.on "object:over", (e) ->
    $("img#magnifier").attr "src", e.target._element.attributes.src.value

  hand_canvas.on "object:out", (e) ->
    $("img#magnifier").attr "src", "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
