chai = require 'chai'
chai.should()

{Player} = require '../server/models/_player'

describe 'Player', ->
  it 'exists', ->
    Player.should.be.ok
  it 'can be instantiated', ->
    player = new Player
    player.should.be.instanceOf Player

describe 'Player.applyClickMod()', ->
  player = new Player
  it 'should decrement positive click costs', ->
    [cost, mod] = [1, -1]
    finalCost = player.applyClickMod(cost, mod)
    finalCost.should.equal 0
  it 'should not take the click cost below 0', ->
    [cost, mod] = [0, -1]
    finalCost = player.applyClickMod(cost, mod)
    finalCost.should.equal 0

describe 'Player.applyCreditMod()', ->
  player = new Player
  it 'should decrement positive credit costs', ->
    [cost, mod] = [1, -1]
    finalCost = player.applyCreditMod(cost, mod)
    finalCost.should.equal 0
  it 'should not take the credit cost below 0', ->
    [cost, mod] = [0, -1]
    finalCost = player.applyCreditMod(cost, mod)
    finalCost.should.equal 0

describe 'Player.hasEnoughCredits()', ->
  player = new Player {stats: {credits: 1}}
  it 'should return true if player has enough credits', ->
    result = player.hasEnoughCredits 1
    result.should.be.true
  it 'should return false if player has enough credits', ->
    result = player.hasEnoughCredits 2
    result.should.be.false

describe 'Player.hasEnoughClicks()', ->
  player = new Player {stats: {clicks: 1}}
  it 'should return true if player has enough clicks', ->
    result = player.hasEnoughClicks 1
    result.should.be.true
  it 'should return false if player has enough clicks', ->
    result = player.hasEnoughClicks 2
    result.should.be.false

describe 'Player.canEndTurn()', ->
  player = new Player {hand: [{}, {}, {}, {}], stats: {handLimit: 5}}
  it 'should succeed if hand is smaller than hand limit', ->
    result = player.canEndTurn()
    result.should.be.true
  it 'should succeed if hand is equal to hand limit', ->
    player.hand.push {}
    result = player.canEndTurn()
    result.should.be.true
  it 'should fail if hand is greater than hand limit', ->
    player.hand.push {}
    result = player.canEndTurn()
    result.should.be.false
