Template.sidebarStats.currentTurn = ->
    game()['turn']

Template.sidebarStats.runnerScore = ->
    game()['runner']['stats']['score']

Template.sidebarStats.runnerCredits = ->
    game()['runner']['stats']['credits']
