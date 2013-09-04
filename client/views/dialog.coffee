Template.moddedDialog.title = ->
  if Session.equals "runnerIsModded", true
    "Modded"


Template.moddedDialog.rendered = ->
  opt = { modal: true, closeOnEscape: false, width: 900, dialogClass: "no-close" }

  if Session.equals "showDialog", true
    $( '#moddedDialog' ).dialog( opt )
  else
    $(".ui-dialog-content").dialog().dialog( 'close' );


Template.moddedDialog.description = ->
  if Session.equals "runnerIsModded", true
    'Install a program or a piece of hardware, lowering the install cost by 3.'


Template.moddedDialog.cardChoices = ->
  cards = Session.get "programsAndHardwareInHand"


Template.moddedDialog.events 'click button': (e) ->
    cardId = e.target.dataset.id
    cardType = e.target.dataset.cardtype

    if cardType is 'Hardware'
      Meteor.call 'doInstallHardwareAction', myself(), 'runner.hand', cardId, 'Modded', (err, result) ->
        console.log err if err

      Session.set 'showDialog', false
