#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------

Template.main_canvas.rendered = ->
  main_canvas = new fabric.Canvas("main_canvas")
  main_canvas.hoverCursor = "pointer"
  add_hover_helper main_canvas

  main_canvas.showGameStartImages myself(), game()
  main_canvas.showGameStartText myself()

  main_canvas.on "object:over", (e) ->
    meta = e.target.metadata
    imgSrc = if meta.trueSrc then meta.trueSrc else meta.src
    $("img#magnifier").attr "src", imgSrc


  main_canvas.on "object:out", (e) ->
    blankPixel = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
    $("img#magnifier").attr "src", blankPixel


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
    main_canvas.displayDiscardPiles result


  # Refresh display every time the Runner's in-play resources change
  Meteor.call "getRunnerResources", myself(), (err, result) ->
    console.log err if err
    main_canvas.displayRunnerResources result


  # Refresh display every time the Runner's in-play hardware change
  Meteor.call "getRunnerHardware", myself(), (err, result) ->
    console.log err if err
    main_canvas.displayRunnerHardware result


  # Refresh display every time the Corp's remote servers change
  Meteor.call "getRemoteServers", myself(), (err, result) ->
    console.log err if err
    main_canvas.displayRemoteServers result


Template.main_canvas.canvasHeight = () ->
  CANVAS['height']


Template.main_canvas.canvasWidth = () ->
  CANVAS['width']


#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
