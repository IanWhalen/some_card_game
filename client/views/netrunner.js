//-----------------------------------------------------------------------------
// Board Templates
//-----------------------------------------------------------------------------

Template.board.show = function () {
  // only show board if we're in a game
  return game();
};


Template.board.selected = function (i) {
  return Session.get('selected_' + i);
};


//////
////// Initialization
//////

Meteor.startup(function () {
  // Allocate a new player id.
  //
  // XXX this does not handle hot reload. In the reload case,
  // Session.get('player_id') will return a real id. We should check for
  // a pre-existing player, and if it exists, make sure the server still
  // knows about us.
  var player_id = Players.insert({name: '', idle: false});
  Session.set('player_id', player_id);

  // subscribe to all the players, the game i'm in, and all
  // the words in that game.
  Deps.autorun(function () {
    Meteor.subscribe('players');

    if (Session.get('player_id')) {
      var me = myself();
      if (me && me.game_id) {
        Meteor.subscribe('games', me.game_id);
      }
    }
  });
});
