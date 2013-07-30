class @Card
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  getActionDataFromCard: (action) ->
    if @.getSideLoc() == 'hand'
      arr = 'handActions'
    if @.getSideLoc() == 'resources'
      arr = 'boardActions'

    actionObj = _.find @[arr], (obj) -> action of obj
    actionObj[action]


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

    @incEmbeddedIntegerField gameId, findObj, updateObj, amount
    @counters += amount


  incEmbeddedIntegerField: (findObj, updateObj) ->
    Games.update(findObj, updateObj)
