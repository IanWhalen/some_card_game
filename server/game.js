////////// Server only logic //////////

// Functions that can be invoked over the network by clients.
Meteor.methods({
  start_new_game: function () {
    // try to find a ready "corp" and ready "runner"
    var corp = player_is_ready("corp");
    var runner = player_is_ready("runner");

    // if so, setup new game board
    if (corp && runner) {
      var game_id = Games.insert({ corp:           { player: corp },
                                   runner:         { player: runner },
                                   current_player: runner,
                                   turn:           1
                                 });

      RUNNER["deck"] = RUNNER_DECK;
      Games.update( game_id,
                    { $set: { "runner" : RUNNER }});

      // move both players from the lobby to the game
      Players.update({'_id': { $in: [corp, runner] }},
                     {$set: {game_id: game_id}},
                     {multi: true});

      return game_id;
    }
  },

  draw_card: function (game, player) {
    if (player._id === game.current_player) {
      var card = get_top_card_from_deck(game, player);

      if (card) {
        move_top_card_from_deck_to_hand(game, player, card);
      }
    }
  },

  get_hand: function (game, player) {
    return game[player.side]["hand"] || new Array(0);
  },

  keepalive: function (player_id) {
    check(player_id, String);
    Players.update({_id: player_id},
                  {$set: {last_keepalive: (new Date()).getTime(),
                          idle: false}});
  }
});

Meteor.setInterval(function () {
  var now = (new Date()).getTime();
  var idle_threshold = now - 7*1000; // 7 sec
  var remove_threshold = now - 30*1000; // 30 sec

  Players.update({last_keepalive: {$lt: idle_threshold}},
                 {$set: {idle: true, ready: false}});
}, 30*1000);