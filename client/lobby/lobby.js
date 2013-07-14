//-----------------------------------------------------------------------------
// Lobby Templates
//-----------------------------------------------------------------------------

Template.lobby.show = function () {
  // only show lobby if we're not in a game
  return !game();
};


Template.lobby.waiting = function () {
  // Return a list of all players who have entered a name,
  // entered a valid side, and are not in a game
  var players = Players.find({_id: {$ne: Session.get('player_id')},
                              name: {$ne: ''},
                              side: {$in: ['corp', 'runner']},
                              game_id: {$exists: false}});

  return players;
};


Template.lobby.disabled = function () {
  // Player must have chosen a name and a valid side
  // for the 'Ready' checkbox to be active

  var me = myself();
  if (me && me.name && (me.side == 'corp' || me.side == 'runner'))
    return '';
  return 'disabled="disabled"';
};


//-----------------------------------------------------------------------------
// Lobby Events
//-----------------------------------------------------------------------------

Template.lobby.events({
  'keyup input#myname': function (evt) {
    // As player enters a name, pass it to the database
    // If user clears their name, uncheck the Ready checkbox if needed
    // and clear their Ready status in the database
    var name = $('#lobby input#myname').val().trim();

    if (name === '') {
      $("input#ready").prop("checked", false);
      set_player_as_not_ready();
    } else {
      Players.update(Session.get('player_id'), {$set: {name: name}});
    }
  },

  'keyup input#myside': function (evt) {
    // As player enters a side, pass it to the database
    // If user enters an invalid side, uncheck the Ready checkbox if needed
    // and clear their Ready status in the database
    var side = $('#lobby input#myside').val().trim();

    if (side === 'corp' || side === 'runner') {
      Players.update(Session.get('player_id'), {$set: {side: side}});
    } else {
      Players.update(Session.get('player_id'), {$unset: {side: ''}});
      $("input#ready").prop("checked", false);
      set_player_as_not_ready();
    }
  },

  'change input#ready': function (evt) {
    if (evt.target.checked) {
      // Every time someone marks themselves as ready,
      // we check for a valid matchup
      set_player_as_ready();
      Meteor.call('start_new_game');
    } else {
      set_player_as_not_ready();
    }
  }
});