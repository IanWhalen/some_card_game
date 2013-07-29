class @Card
  constructor: (obj) ->
    for key, value of obj
      @[key] = value

  getActionDataFromCard: (action) ->
    actionObj = _.find @["actions"], (obj) ->
      action of obj
    actionObj[action]
