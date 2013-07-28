game = function(player) {
  return Games.findOne(player.game_id);
};


player_is_ready = function(side) {
  var p = Players.findOne({ game_id: null,
                            idle: false,
                            side: side,
                            ready: true });

  if (p) {
    return p._id;
  } else {
    return false;
  }
};

getOppSide = function(side) {
  if (side === "corp") {
    return "runner";
  } else if (side === "runner") {
    return "corp";
  } else {
    console.log("getOppSide got bad input: " + side);
  }
};


getOppPlayerObj = function(playerObj) {
  var gameObj = game(playerObj);
  var oppSideString = getOppSide(playerObj['side']);

  return Players.findOne({game_id: gameObj._id, side: oppSideString});
}


switchCurrentPlayer = function(gameObj, playerObj) {
  var oppSide = getOppSide(playerObj.side);
  var playerId = gameObj[oppSide]['playerId'];

  setCurrentPlayerField(gameObj, playerId);
};


//-----------------------------------------------------------------------------
// Server-side card movement functions
//-----------------------------------------------------------------------------

var getTopCardFromDeck = function(_game, _player) {
  // Returns the top card from a deck but does not remove it.
  //
  // This is a necessary helper function to get the actual card
  // before popping it.
  // TODO: handle empty deck
  return _game[_player["side"]]["deck"].slice(-1)[0];
};


move_top_card_from_deck_to_hand = function(game, player, card) {
  // Pops from the "deck" array and pushes to the "hand" array.
  //
  // Assumes we have already figured out the top card of the deck.
  // TODO: handle empty deck
  var updateDeck = {};
  var updateHand = {};

  updateDeck[player.side + ".deck"] = 1;
  updateHand[player.side + ".hand"] = card;

  Games.update(game._id, {$pop:  updateDeck});
  Games.update(game._id, {$push: updateHand});
};


//-----------------------------------------------------------------------------
// CARD ACTIONS
//
// These functions are all used as keys in the actions array contained within
// each card object.  They are globally accessible and should simply provide
// an english language interface to the underlying game state modifiers.
//-----------------------------------------------------------------------------

add1Credit = function(playerObj) {
  modifyCredits(playerObj, 1);
};

add9Credits = function(playerObj) {
  modifyCredits(playerObj, 9);
};

draw1Card = function(playerObj) {
  drawCards(playerObj, 1);
};

draw3Cards = function(playerObj) {
  drawCards(playerObj, 3);
};


//-----------------------------------------------------------------------------
// Local card action helpers
//-----------------------------------------------------------------------------

var drawCards = function (playerObj, amount) {
  for (var i = 0; i < amount; i++) {
    var gameObj = game(playerObj);
    var cardObj = getTopCardFromDeck(gameObj, playerObj);

    if (cardObj) {
      move_top_card_from_deck_to_hand(gameObj, playerObj, cardObj);
    } else {
      console.log("Can not draw. Deck is empty.");
    }
  }
};


var modifyCredits = function(playerObj, amount) {
  var targetField = playerObj['side'] + ".stats.credits";

  modifyIntegerField(playerObj, targetField, amount);
};


var modifyClicks = function(playerObj, amount) {
  var targetField = playerObj['side'] + ".stats.clicks";

  modifyIntegerField(playerObj, targetField, amount);
};


//-----------------------------------------------------------------------------
// ECONOMY HANDLERS
//-----------------------------------------------------------------------------

payAllCosts = function(playerObj, creditCost, clickCost) {
  modifyCredits(playerObj, -1 * creditCost);
  modifyClicks(playerObj, -1 * clickCost);
};


resetCorpClicks = function(playerObj) {
  var targetField = "corp.stats.clicks";
  var clicks = 3;

  setIntegerField(playerObj, targetField, clicks);
};


resetRunnerClicks = function(playerObj) {
  var targetField = "runner.stats.clicks";
  var clicks = 4;

  setIntegerField(playerObj, targetField, clicks);
};


setPlayerClicksToZero = function(playerObj) {
  var targetField = playerObj['side'] + ".stats.clicks";
  clicks = 0;

  setIntegerField(playerObj, targetField, clicks);
}

//-----------------------------------------------------------------------------
// DATABASE FUNCTIONS
//
// These functions all touch the database and thus must call, modify, and
// discard a game object solely within their own scope.
//-----------------------------------------------------------------------------

moveCardFromHandToDiscard = function(playerObj, cardObj) {
  // Finds and removes from the "hand" array and pushes to the "discard" array.
  var gameObj = game(playerObj);

  var updateHand = {};
  updateHand[playerObj.side + ".hand"] = cardObj;

  var updateDiscard = {};
  updateDiscard[playerObj.side + ".discard"] = cardObj;

  Games.update(gameObj._id, {$pull:  updateHand});
  Games.update(gameObj._id, {$push: updateDiscard});
};


var setIntegerField = function(playerObj, targetField, amount) {
  var game_id = game(playerObj)['_id'];

  var modObj = {};
  modObj[targetField] = amount;

  Games.update(game_id, { $set: modObj } );
}


var modifyIntegerField = function(playerObj, targetField, amount) {
  var game_id = game(playerObj)['_id'];

  var modObj = {};
  modObj[targetField] = amount;

  Games.update(game_id, { $inc: modObj } );
};


var setCurrentPlayerField = function(gameObj, playerId) {
  Games.update(gameObj._id, {$set: { current_player : playerId}});
};
