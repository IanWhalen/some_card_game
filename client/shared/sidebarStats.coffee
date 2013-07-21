# TODO: This is a security hole since it pulls the whole game object
# onto the client side.  Need to instead get the game object server-side
# and only return the public data to this controller.

Template.sidebarStats.currentTurn = ->
    game()['turn']

Template.sidebarStats.runnerScore = ->
    game()['runner']['stats']['score']

Template.sidebarStats.runnerCredits = ->
    game()['runner']['stats']['credits']

Template.sidebarStats.runnerClicks = ->
    game()['runner']['stats']['clicks']

Template.sidebarStats.corpScore = ->
    game()['corp']['stats']['score']

Template.sidebarStats.corpCredits = ->
    game()['corp']['stats']['credits']

Template.sidebarStats.corpClicks = ->
    game()['corp']['stats']['clicks']
