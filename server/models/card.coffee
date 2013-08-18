class @Card
  constructor: (obj) ->
    for key, value of obj
      @[key] = value


  getActionDataFromCard: (action) ->
    arr = 'handActions' if @loc == 'hand'
    arr = 'boardActions' if @loc == 'resources'

    if @loc is 'remoteServer' and @cardType in ['Asset', 'ICE'] and @rezzed is false
      arr = 'unrezzedActions'

    return actionObj = _.find @[arr], (obj) -> obj['action'] = action


  incCounters: (gameId, amount) ->
    findObj = {}
    findObj._id = gameId
    findObj[@owner + '.' + @loc + '._id'] = @_id

    updateObj = {}
    updateEmbeddedObj = {}
    updateEmbeddedObj["#{@owner}.#{@loc}.$.counters"] = amount
    updateObj['$inc'] = updateEmbeddedObj

    @_incEmbeddedIntegerField findObj, updateObj
    @counters += amount


  _incEmbeddedIntegerField: (findObj, updateObj) ->
    Games.update(findObj, updateObj)
