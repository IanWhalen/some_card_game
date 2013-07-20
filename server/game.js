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

  get_hands: function (game, player) {
    var handPair = [];
    handPair.push( game[player.side]["hand"] || [] );

    try {
      oppHandLength = game[getOppSide(player.side)]["hand"].length;
    } catch (e) {
      oppHandLength = 0;
    }

    handPair.push( oppHandLength );

    return handPair;
  },

  doCardAction: function (playerObj, gameLoc, cardId, action) {
    var gameObj = game(playerObj);
    var side = gameLoc.split(".")[0]; // e.g. "runner"
    var loc = gameLoc.split(".")[1];  // e.g. "hand" or "deck"


    // First: confirm card is in expected place in game state
    var confirmCardIsInLocation = function () {
      var arr = gameObj[side][loc];
      var cardObj = _.find(arr, function(obj) { return obj._id == cardId; });
      return cardObj;
    };
    var cardObj = confirmCardIsInLocation();


    //  Second: get the specific action object
    var getActionObj = function () {
      return _.find(cardObj['actions'], function(obj) { return action in obj; });
    };
    var actionObj = getActionObj();


    // Third: confirm player has enough credits
    var confirmPlayerHasCredits = function () {
      return gameObj[side]['stats']['credits'] >= actionObj[action]['credit_cost'];
    };


    // Fourth: confirm player has enough clicks
    var confirmPlayerHasClicks = function () {
      return gameObj[side]['stats']['clicks'] >= actionObj[action]['click_cost'];
    };



    // console.log( global[action](arg1, arg2) );
    if (confirmPlayerHasCredits() && confirmPlayerHasClicks()) {
      try {
        var clickCost = actionObj[action]['click_cost'];
        var creditCost = actionObj[action]['credit_cost'];
        console.log(creditCost);
        global['payAllCosts'](gameObj, playerObj, creditCost, clickCost);

        global[action](gameObj, playerObj);
      } catch (e){
        console.log(e);
      }
    }
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