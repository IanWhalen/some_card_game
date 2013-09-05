Template.runStatus.rendered = ->
  Meteor.call "getRunStatus", myself(), (err, result) ->
    console.log err if err
    Session.set "runInProgress", result

Template.runStatus.runInProgress = ->
  return Session.get 'runInProgress'

Template.runStatus.targetName = ->
  run = Session.get 'runInProgress'
  return run.targetName
