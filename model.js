////////// Shared code (client and server) //////////

Games = new Meteor.Collection('games');


Players = new Meteor.Collection('players');
// {name: 'Ian', game_id: 123, side: 'runner'}


if (Meteor.isServer) {
  // publish all the non-idle players.
  Meteor.publish('players', function () {
    return Players.find({idle: false});
  });

  // publish single games
  Meteor.publish('games', function (id) {
    check(id, String);
    return Games.find({_id: id});
  });
}

