chai = require 'chai'
chai.should()

{Player} = require '../server/models/_player'

describe 'Player', ->
  it 'exists', ->
    Player.should.be.ok
  it 'can be instantiated', ->
    player = new Player
    player.should.be.instanceOf Player

describe 'Player cost modification functions', ->
  player = new Player
  it 'should decrement positive click costs', ->
    [cost, mod] = [1, -1]
    finalCost = player.applyClickMod(cost, mod)
    finalCost.should.equal 0
  it 'should not take the click cost below 0', ->
    [cost, mod] = [0, -1]
    finalCost = player.applyClickMod(cost, mod)
    finalCost.should.equal 0
  it 'should decrement positive credit costs', ->
    [cost, mod] = [1, -1]
    finalCost = player.applyCreditMod(cost, mod)
    finalCost.should.equal 0
  it 'should not take the credit cost below 0', ->
    [cost, mod] = [0, -1]
    finalCost = player.applyCreditMod(cost, mod)
    finalCost.should.equal 0

describe 'Player resource validation functions', ->
  player = new Player {stats: {clicks: 1, credits: 1}}
  it 'should return true if player has enough credits', ->
    result = player.hasEnoughCredits 1
    result.should.equal true
  it 'should return false if player has enough credits', ->
    result = player.hasEnoughCredits 2
    result.should.equal false
  it 'should return true if player has enough clicks', ->
    result = player.hasEnoughCredits 1
    result.should.equal true
  it 'should return false if player has enough clicks', ->
    result = player.hasEnoughCredits 2
    result.should.equal false