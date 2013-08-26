chai = require 'chai'
chai.should()

{Corp} = require '../server/models/corp'

describe 'Corp', ->
  it 'exists', ->
    Corp.should.be.ok
  it 'can be instantiated', ->
    corp = new Corp
    corp.should.be.instanceOf Corp
