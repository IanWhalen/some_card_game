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
      CORP["deck"] = CORP_DECK;
      Games.update( game_id,
                    { $set: { "runner" : RUNNER, "corp" : CORP }});

      // move both players from the lobby to the game
      Players.update({'_id': { $in: [corp, runner] }},
                     {$set: {game_id: game_id}},
                     {multi: true});

      return game_id;
    }
  },

  drawCard: function (playerObj) {
    var gameObj = game(playerObj);
    if (playerObj._id === gameObj.current_player) {
      var cardObj = get_top_card_from_deck(gameObj, playerObj);

      if (cardObj) {
        move_top_card_from_deck_to_hand(gameObj, playerObj, cardObj);
      }
    }
  },

  get_hands: function (game, player) {
    // This function returns a 2-element array.  The first element is an
    // array of the cards in the player's own hand.  The second element
    // is the size of the opponents hand.
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

  getTopOfDiscardPiles: function (playerObj) {
    var discardPair = {};

    if ( game(playerObj)['runner']['discard'] ) {
      var runnerDiscardPile = game(playerObj)['runner']['discard'];
      discardPair['runner'] = runnerDiscardPile[runnerDiscardPile.length-1];
    }

    if ( game(playerObj)['corp']['discard'] ) {
      var corpDiscardPile = game(playerObj)['corp']['discard'];
      discardPair['corp'] = corpDiscardPile[corpDiscardPile.length-1];
    }

    return discardPair;
  },

  doCardAction: function (playerObj, gameLoc, cardId, action) {
    var gameObj = game(playerObj);
    var side = gameLoc.split(".")[0]; // e.g. "runner"
    var loc = gameLoc.split(".")[1];  // e.g. "hand" or "deck"


    // First: confirm card is in expected place in game state
    var confirmCardIsInLocation = function () {
      return _.find(gameObj[side][loc], function(obj) { return obj._id == cardId; });
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


    if (confirmPlayerHasCredits() && confirmPlayerHasClicks()) {
      var clickCost = actionObj[action]['click_cost'];
      var creditCost = actionObj[action]['credit_cost'];

      global['payAllCosts'](gameObj, playerObj, creditCost, clickCost);
      global[action](gameObj, playerObj);
      global['moveCardFromHandToDiscard'](gameObj, playerObj, cardObj);
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