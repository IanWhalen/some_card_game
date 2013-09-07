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
      RUNNER['deck']['cards'] = _.shuffle(RUNNER_DECK);
      RUNNER['playerId'] = runnerId;
      CORP['deck']['cards'] = _.shuffle(CORP_DECK);
      CORP['playerId'] = corpId;

      var gameId = Games.insert({ corp:           CORP,
                                  runner:         RUNNER,
                                  current_player: corpId,
                                  turn:           0
                                 });


      // move both players from the lobby to the game
      Players.update({'_id': { $in: [corpId, runnerId] }},
                     {$set: {game_id: gameId}},
                     {multi: true});


      // Run startup operations
      var game = new Game(Games.findOne(gameId));
      game.newGameSetup();

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
      var game = getGameObj( playerObj );
      var player = ( playerObj.side === 'corp' ) ?
        new Corp( game.corp, game._id ) :
        new Runner( game.runner, game._id );

    if (player.playerId === game.current_player) {
      var clickCost = 1;
      var creditCost = 0;

      if (player.hasEnoughClicks(clickCost)) {
        player.payAllCosts(1, 0);
        player.draw1Card();

        var line = 'The ' + playerObj['side'].capitalize() + " spends 1 click and draws 1 card.";
        game.logForBothSides(line);
      }
    } else {
      return false;
    }
  },


  doCreditGainAction: function(playerObj) {
    var game = getGameObj(playerObj);
    var player = (playerObj['side'] === 'corp') ?
      new Corp( game['corp'], game['_id'] ) :
      new Runner( game['runner'], game['_id'] );

    if (player.playerId === game.current_player) {
      var clickCost = 1;
      var creditCost = 0;

      if (player.hasEnoughClicks(clickCost)) {
        player.payAllCosts(1, 0);
        player.add1Credit();

        var line = 'The ' + playerObj['side'].capitalize() + " spends 1 click and gains 1 credit.";
        game.logForBothSides(line);
      }
    } else {
      return false;
    }
  },


  doEndTurnAction: function(currentPlayerObj) {
    var game = getGameObj(currentPlayerObj);

    if (currentPlayerObj['side'] === 'corp') {
      var player = new Corp( game.corp, game._id );
      var opponent = new Runner( game.runner, game._id );
    } else {
      var opponent = new Corp( game.corp, game._id );
      var player = new Runner( game.runner, game._id );
    }


    if (player.playerId === game.current_player) {
      if (player.canEndTurn()) {
        game.logForBothSides('Current player has ended their turn.');
        player.setClicksToZero();
        opponent.startTurn();
        switchCurrentPlayer(game, currentPlayerObj);
      } else {
        player.logForSelf("You must discard before ending your turn.");
        return false;
      }
    }
  },


  doInstallResourceAction: function (playerObj, cardId) {
    var game = getGameObj(playerObj);
    var runner = new Runner(game.runner, game._id);

    if (runner.playerId === game.current_player) {
      return runner.installResource(cardId, 'foo');
    } else {
      return false;
    }
  },


  doInstallHardwareAction: function (playerObj, cardId, costMod) {
    var game = getGameObj(playerObj);
    var runner = new Runner(game.runner, game._id);

    if (runner.playerId === game.current_player) {
      return runner.installHardware(cardId, costMod);
    } else {
      return false;
    }
  },


  createNewRemoteServer: function (playerObj) {
    if (playerObj.side === 'corp') {
      var game = getGameObj(playerObj);

      return game.createNewRemoteServer();
    }
  },


  doInstallAssetAction: function (playerObj, cardId, server) {
    var game = getGameObj(playerObj);
    var corp = new Corp(game.corp, game._id);
    if (server !== 'newServer' && typeof server === 'string') {
      server = new RemoteServer( _.find(corp.remoteServers, function(obj) {
        return obj._id === server;
      }), game._id );
    }

    return corp.installAsset(cardId, server);
  },


  doInstallICEAction: function (playerObj, cardId, server) {
    var game = getGameObj(playerObj);
    var corp = new Corp(game.corp, game._id);

    if (server === 'deck') {
      server = new Deck('corp', game._id);
    } else if (server !== 'newServer' && typeof server === 'string') {
      server = new RemoteServer( server, game._id );
    }

    if (corp.playerId === game.current_player) {
      return corp.installICE(cardId, server);
    } else {
      return false;
    }
  },


  doRezICEAction: function (playerObj, cardId, server) {
    var game = getGameObj(playerObj);
    var corp = new Corp(game.corp, game._id);

    return corp.rezICE(cardId, server);
  },


  doRezAssetAction: function (playerObj, cardId, server) {
    var game = getGameObj(playerObj);
    var corp = new Corp(game.corp, game._id);

    return corp.rezAsset(cardId, server);
  },


  doDiscardFromHandAction: function (playerObj, cardId) {
    var game = getGameObj(playerObj);
    var player = (playerObj['side'] === 'corp') ?
      new Corp( game['corp'], game['_id'] ) :
      new Runner( game['runner'], game['_id'] );

    if (player.playerId === game.current_player) {
      return player.discardFromHand(cardId);
    } else {
      return false;
    }
  },

  //-----------------------------------------------------------------------------
  // RUNNER ACTIONS
  //
  //
  //
  //-----------------------------------------------------------------------------

  doStartRunAction: function (playerObj, targetId) {
    var game = getGameObj( playerObj );

    if (playerObj._id === game.current_player) {
      return game.startRun(targetId);
    } else {
      return false;
    }
  },


  //-----------------------------------------------------------------------------
  // CARD DISPLAY FUNCTIONS
  //
  //
  //-----------------------------------------------------------------------------

  getRemoteServers: function(playerObj) {
    var remotes = getGameObj(playerObj)['corp']['remoteServers'] || [];
    
    for (var i = 0; i < remotes.length; i++) {            // Loop through the list of remote servers
      var server = remotes[i];

      assetsAndAgendas = server['assetsAndAgendas'];
      for (var j = 0; j < assetsAndAgendas.length; j++) { // And loop through each server's assets/agendas
        var card = server['assetsAndAgendas'][j];
        if (card['rezzed'] === false) {                   // If a card hasn't been rezzed
          if (playerObj.side === 'corp') {
            card['trueSrc'] = card['src'];                // Show the Corp the real card when hovering
            card['src'] = 'corp-back.jpg';                // But only show the card back when on the table
          } else {
            var blankCard = {src: 'corp-back.jpg', owner: 'corp'};       // And wipe everything for the Runner
            remotes[i]['assetsAndAgendas'][j] = blankCard;
          }
        }
      }

      installedICE = server['ICE'];
      for (var k = 0; k < installedICE.length; k++) {     // Then loop through each server's ICE
        var ICE = server['ICE'][k];
        if (ICE.rezzed === false) {                       // If a card hasn't been rezzed
          if (playerObj.side === 'corp') {
            ICE['trueSrc'] = ICE['src'];                  // Show the Corp the real card when hovering
            ICE['src'] = 'corp-back.jpg';                 // But only show the card back when on the table
          } else {
            var blankICE = {src: 'corp-back.jpg', owner: 'corp'};        // And wipe everything for the Runner
            blankICE.cardType = 'ICE';
            remotes[i]['ICE'][k] = blankICE;
          }
        }
      }
    }

    return remotes;
  },


  getRunnerResources: function(playerObj) {
    return getGameObj(playerObj)['runner']['resources'] || [];
  },


  getRunnerHardware: function(playerObj) {
    return getGameObj(playerObj)['runner']['hardware'] || [];
  },


  getRunnerHand: function(playerObj) {
    return getGameObj(playerObj)['runner']['hand'] || [];
  },


  getPlayersHands: function (playerObj) {
    var game = getGameObj(playerObj);
    var corp = new Corp( game.corp, game._id );
    var runner = new Runner( game.runner, game._id );
    var playerHands = {};


    if (playerObj.side === 'corp') {
      playerHands['ownHand'] = corp.getHand();
      playerHands['opponentHandSize'] = runner.getHand().length;
    } else if (playerObj.side === 'runner') {
      playerHands['ownHand'] = runner.getHand();
      playerHands['opponentHandSize'] = corp.getHand().length;
    }
    
    return playerHands;
  },


  getTopOfDiscardPiles: function (playerObj) {
    var game = getGameObj( playerObj );
    var cards = {corp: false, runner: false};
    
    var blankCorp = {src: 'corp-back.jpg', loc: 'discard'};

    var runnerDiscard = game.runner.discard;
    cards.runner = runnerDiscard[runnerDiscard.length-1] || false;
    var corpDiscard = game.corp.discard;
    var topCorpCard = corpDiscard[corpDiscard.length-1];

    if (topCorpCard) {
      if (topCorpCard.faceDown === true) {        // If the top card is face down
        if (playerObj.side === 'corp') {
          topCorpCard.trueSrc = topCorpCard.src;  // Show the Corp the real card when hovering
          topCorpCard.src = 'corp-back.jpg';      // But only show the card back when on the table
          cards.corp = topCorpCard;
        } else {
          cards.corp = blankCorp;                 // And show nothing to the Runner
        }
      } else {                                    // If the top card is face up
        cards.corp = topCorpCard;                 // Show the card to both players
      }
    } else {                                      // If there is no top card
      cards.corp = false;                         // Show nothing
    }
    return cards;
  },


  doCardAction: function (playerObj, cardId, action) {
    var game = getGameObj(playerObj);
    var player = (playerObj['side'] === 'corp') ?
      new Corp( game['corp'], game['_id'] ) :
      new Runner( game['runner'], game['_id'] );

    return player.doCardAction(cardId, action);
  },


  //-----------------------------------------------------------------------------
  // NETWORK FUNCTIONS
  //
  //
  //-----------------------------------------------------------------------------

  keepalive: function (player_id) {
    check(player_id, String);
    Players.update({_id: player_id},
                  {$set: {last_keepalive: (new Date()).getTime(),
                          idle: false}});
  },

  //-----------------------------------------------------------------------------
  // GAME STATUS FUNCTIONS
  //
  //
  //-----------------------------------------------------------------------------

  getRunStatus: function (playerObj) {
    var game = getGameObj(playerObj);
    if (game.run !== undefined && game.run !== false) {
      return game.run;
    } else {
      return false;
    }
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
