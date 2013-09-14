#-----------------------------------------------------------------------------
# Canvas Templates
#-----------------------------------------------------------------------------

Template.main_canvas.rendered = ->
  cvs = new fabric.NetrunnerCanvas('main_canvas', {hoverCursor: "pointer"})

  add_hover_helper cvs

  cvs.showGameStartImages myself(), game()
  cvs.showGameStartText myself()

  cvs.on "object:over", (e) ->
    if not e.target.metadata
      return false

    meta = e.target.metadata
    imgSrc = if meta.trueSrc then meta.trueSrc else meta.src
    $("img#magnifier").attr "src", imgSrc


  cvs.on "object:out", (e) ->
    blankPixel = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
    $("img#magnifier").attr "src", blankPixel


  cvs.on "object:selected", (e) ->
    if !cvs._activeGroup && cvs._activeObject
      Session.set "selectedObj", e.target.metadata


  cvs.on "selection:cleared", (e) ->
    Session.set "selectedObj", undefined


  # Refresh display every time either player's hand is changed
  Meteor.call "getPlayersHands", myself(), (err, result) ->
    console.log err if err
    cvs.displayPlayerHands result


  # Refresh display every time either player's discard pile is changed
  Meteor.call "getTopOfDiscardPiles", myself(), (err, result) ->
    console.log err if err
    cvs.displayDiscardPiles result


  # Refresh display every time the Runner's in-play resources change
  Meteor.call "getRunnerResources", myself(), (err, result) ->
    console.log err if err
    cvs.displayRunnerResources result


  # Refresh display every time the Runner's in-play hardware change
  Meteor.call "getRunnerHardware", myself(), (err, result) ->
    console.log err if err
    cvs.displayRunnerHardware result


  # Refresh display every time the Corp's remote servers change
  Meteor.call "getRemoteServers", myself(), (err, result) ->
    console.log err if err
    cvs.displayRemoteServers result


  # Refresh display every time the Corp's Deck ICE change
  Meteor.call "getDeckICE", myself(), (err, result) ->
    console.log err if err
    cvs.displayDeckICE result


  # Refresh display every time the Corp's Discard ICE change
  Meteor.call "getDiscardICE", myself(), (err, result) ->
    console.log err if err
    cvs.displayDiscardICE result


Template.main_canvas.canvasHeight = () ->
  CANVAS['height']


Template.main_canvas.canvasWidth = () ->
  CANVAS['width']


#-----------------------------------------------------------------------------
# Canvas Events
#-----------------------------------------------------------------------------
Template.main_canvas.events {}
