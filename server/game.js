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
    var gameObj = getGameObj(playerObj);
    var clickCost = 1;
    var creditCost = 0;

    if (gameObj[playerObj.side]['stats']['clicks'] >= clickCost) {
      gameObj.payAllCosts(playerObj, 0, 1)
      gameObj.draw1Card(playerObj)

      var line = 'The ' + playerObj['side'].capitalize() + " spends 1 click and draws 1 card.";
      gameObj.logForBothSides(line);
    }
  },


  doCreditGainAction: function(playerObj) {
    var gameObj = getGameObj(playerObj);

    var clickCost = 1;
    var creditCost = 0;

    if (gameObj[playerObj.side]['stats']['clicks'] >= clickCost) {
      gameObj.payAllCosts(playerObj, 0, 1)
      gameObj.add1Credit(playerObj)

      var line = 'The ' + playerObj['side'].capitalize() + " spends 1 click and gains 1 credit.";
      gameObj.logForBothSides(line);
    }
  },


  doEndTurnAction: function(currentPlayerObj) {
    var gameObj = getGameObj(currentPlayerObj);
    var oppPlayerObj = getOppPlayerObj(currentPlayerObj);

    if (currentPlayerObj['_id'] === gameObj['current_player']) {
      // Get current player to appropriate state
      gameObj.setPlayerClicksToZero(currentPlayerObj);
      // TODO: checkHandSizeAgainstHandLimit();

      // Get next player to appropriate state
      if (currentPlayerObj['side'] === 'runner') {
        gameObj.incTurnCounter();
        gameObj.resetCorpClicks();
        gameObj.draw1Card(oppPlayerObj);
      } else if (currentPlayerObj['side'] === 'corp') {
        gameObj.resetRunnerClicks();
      }

      // Make current player switch official
      switchCurrentPlayer(gameObj, currentPlayerObj);

      var line1 = currentPlayerObj['side'].capitalize() + " has ended their turn.";
      var line2 = '===== It is now the ' + oppPlayerObj['side'].capitalize() + "\'s turn. =====";
      gameObj.logForBothSides(line1);
      gameObj.logForBothSides(line2);
    }
  },


  doInstallResourceAction: function (playerObj, gameLoc, cardId) {
    var gameObj = getGameObj(playerObj);

    gameObj.installResource(playerObj, gameLoc, cardId);
  },


  //-----------------------------------------------------------------------------
  // CARD DISPLAY FUNCTIONS
  //
  //
  //-----------------------------------------------------------------------------

  getRunnerResources: function(playerObj) {
    return getGameObj(playerObj)['runner']['resources'] || [];
  },


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
    var gameObj = getGameObj( playerObj );

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
    var gameObj = getGameObj(playerObj);

    try {
      gameObj.doCardAction(playerObj, gameLoc, cardId, action);
      return true
    } catch (e) {
      return false;
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


Meteor.startup(function () {
  String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
  };
});
