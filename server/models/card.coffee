class @Card
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  getActionDataFromCard: (action) ->
    if @.getSideLoc() == 'hand'
      arr = 'handActions'
    if @.getSideLoc() == 'resources'
      arr = 'boardActions'

    return actionObj = _.find @[arr], (obj) -> obj['action'] = action


  getSide: () ->
    @['gameLoc'].split(".")[0]


  getSideLoc: () ->
    @['gameLoc'].split(".")[1]


  incCounters: (gameId, amount) ->
    findObj = {}
    findObj['_id'] = gameId
    findObj[@gameLoc + '._id'] = @._id

    updateObj = {}
    updateEmbeddedObj = {}
    updateEmbeddedObj[@gameLoc + '.$.counters'] = amount
    updateObj['$inc'] = updateEmbeddedObj

    @_incEmbeddedIntegerField gameId, findObj, updateObj, amount
    @counters += amount


  _incEmbeddedIntegerField: (findObj, updateObj) ->
    Games.update(findObj, updateObj)
