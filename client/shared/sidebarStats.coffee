Template.sidebarStats.currentTurn = ->
    game()['turn']

Template.sidebarStats.runnerScore = ->
    game()['runner']['stats']['score']

Template.sidebarStats.runnerCredits = ->
    game()['runner']['stats']['credits']

Template.sidebarStats.runnerClicks = ->
    game()['runner']['stats']['clicks']
