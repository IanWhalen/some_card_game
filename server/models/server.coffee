class @Server
  constructor: (obj) ->
    for key, value of obj
      @[key] = value
