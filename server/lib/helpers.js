game = function(player) {
  return Games.findOne(player.game_id);
};


getGameObj = function(player) {
  return new Game(Games.findOne(player.game_id));
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
  var oppSideString = getOppSide(playerObj.side);

  return Players.findOne({game_id: gameObj._id, side: oppSideString});
};


switchCurrentPlayer = function(game, playerObj) {
  var oppSide = getOppSide(playerObj.side);
  var playerId = game[oppSide]['playerId'];

  game.setCurrentPlayerField(playerId);
};
