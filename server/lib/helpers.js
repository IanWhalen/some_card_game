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

//-----------------------------------------------------------------------------
// Server-side card movement functions
//-----------------------------------------------------------------------------

get_top_card_from_deck = function(_game, _player) {
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

moveCardFromHandToDiscard = function(gameObj, playerObj, cardObj) {
  // Finds and removes from the "hand" array and pushes to the "discard" array.
  var updateHand = {};
  var updateDiscard = {};

  updateHand[playerObj.side + ".hand"] = cardObj;
  updateDiscard[playerObj.side + ".discard"] = cardObj;

  Games.update(gameObj._id, {$pull:  updateHand});
  Games.update(gameObj._id, {$push: updateDiscard});
  console.log(gameObj);
};

//-----------------------------------------------------------------------------
// Card actions
//-----------------------------------------------------------------------------

add9Credits = function(gameObj, playerObj) {
  modifyCredits(gameObj, playerObj, 9);
};


//-----------------------------------------------------------------------------
// Local card action helpers
//-----------------------------------------------------------------------------

var modifyCredits = function(gameObj, playerObj, amount) {
  var targetField = playerObj['side'] + ".stats.credits";

  modifyIntegerField(gameObj._id, targetField, amount);
};


var modifyClicks = function(gameObj, playerObj, amount) {
  var targetField = playerObj['side'] + ".stats.clicks";

  modifyIntegerField(gameObj._id, targetField, amount);
};


var modifyIntegerField = function(game_id, targetField, amount) {
  var modObj = {};

  modObj[targetField] = amount;

  Games.update(game_id, { $inc: modObj } );
};


//-----------------------------------------------------------------------------
// Economy functions
//-----------------------------------------------------------------------------

payAllCosts = function(gameObj, playerObj, creditCost, clickCost) {
  modifyCredits(gameObj, playerObj, -1 * creditCost);
  modifyClicks(gameObj, playerObj, -1 * clickCost);
};
