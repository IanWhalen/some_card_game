class @Runner extends @Player
  constructor: (obj) ->
    for key, value of obj
      @[key] = value
