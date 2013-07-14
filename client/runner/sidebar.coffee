Template.sidebar.playerSide = ->
  myself().side

Template.sidebar.events "click button#draw_card": ->
  Meteor.call "draw_card", game(), myself()