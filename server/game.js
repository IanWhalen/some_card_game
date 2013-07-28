////////// Server only logic //////////

// Functions that can be invoked over the network by clients.
Meteor.methods({
  //-----------------------------------------------------------------------------
  // NEW GAME INITIALIZATION
  //
  // 
  //-----------------------------------------------------------------------------

  start_new_game: function () {
    // try to find a ready "corp" and ready "runner"
    var corpId = player_is_ready("corp");
    var runnerId = player_is_ready("runner");

    // if so, setup new game board
    if (corpId && runnerId) {
      var gameId = Games.insert({ corp:           { player: corpId },
                                  runner:         { player: runnerId },
                                  current_player: runnerId,
                                  turn:           1
                                 });

      RUNNER["deck"] = RUNNER_DECK;
      RUNNER['playerId'] = runnerId;
      CORP["deck"] = CORP_DECK;
      CORP['playerId'] = corpId;
      Games.update( gameId,
                    { $set: { "runner" : RUNNER, "corp" : CORP }});

      // move both players from the lobby to the game
      Players.update({'_id': { $in: [corpId, runnerId] }},
                     {$set: {game_id: gameId}},
                     {multi: true});

      return gameId;
    }
  },


  //-----------------------------------------------------------------------------
  // SHARED DEFAULT ACTIONS
  //
  // These are the shared functions which are executed when a player chooses to
  // use one of their default actions (as opposed to a card's actions).
  //-----------------------------------------------------------------------------

  doDrawAction: function(playerObj) {
    var gameObj = game(playerObj);
    var clickCost = 1;
    var creditCost = 0;

    if (gameObj[playerObj.side]['stats']['clicks'] >= clickCost) {
      global['payAllCosts'](playerObj, 0, 1);
      global['draw1Card'](playerObj);
    }
  },


  doCreditGainAction: function(playerObj) {
    var gameObj = game(playerObj);
    var clickCost = 1;
    var creditCost = 0;

    if (gameObj[playerObj.side]['stats']['clicks'] >= clickCost) {
      global['payAllCosts'](playerObj, 0, 1);
      global['add1Credit'](playerObj);
    }
  },


  doEndTurnAction: function(currentPlayerObj) {
    var gameObj = getGameObj(currentPlayerObj);

    if (currentPlayerObj['_id'] === gameObj['current_player']) {
      // Get current player to appropriate state
      gameObj.setPlayerClicksToZero();
      // TODO: checkHandSizeAgainstHandLimit();

      // Get next player to appropriate state
      if (currentPlayerObj['side'] === 'runner') {
        gameObj.resetCorpClicks();
        global['draw1Card'](getOppPlayerObj(currentPlayerObj));
      } else if (currentPlayerObj['side'] === 'corp') {
        gameObj.resetRunnerClicks();
      }

      // Make current player switch official
      switchCurrentPlayer(gameObj, currentPlayerObj);
    }
  },


  //-----------------------------------------------------------------------------
  // CARD DISPLAY FUNCTIONS
  //
  //
  //-----------------------------------------------------------------------------

  getPlayersHands: function (game, player) {
    // This function returns a 2-element array.  The first element is an
    // array of the cards in the player's own hand.  The second element
    // is the size of the opponents hand.
    var handPair = [];

    handPair.push( game['runner']["hand"] || [] );
    handPair.push( game['corp']["hand"] || [] );

    return handPair;
  },


  getTopOfDiscardPiles: function (playerObj) {
    var discardPair = {};
    var gameObj = game( playerObj );

    if (gameObj['runner']['discard']) {
      var runnerDiscardPile = gameObj['runner']['discard'];
      discardPair['runner'] = runnerDiscardPile[runnerDiscardPile.length-1];
    } else {
      discardPair['runner'] = false;
    }

    if (gameObj['corp']['discard']) {
      var corpDiscardPile = gameObj['corp']['discard'];
      discardPair['corp'] = corpDiscardPile[corpDiscardPile.length-1];
    } else {
      discardPair['corp'] = false;
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

      global['payAllCosts'](playerObj, creditCost, clickCost);
      global[action](playerObj);
      global['moveCardFromHandToDiscard'](playerObj, cardObj);
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