ObjectID    = require('mongodb').ObjectID
_           = require 'underscore'
User        = require '../lib/user'
Game        = require '../lib/game'
Q = require 'q'

good_db = null
Model = require '../lib/model'
setup_db((err, db) -> good_db = Model.DB = db)

describe '_', ->
  describe '#pick', ->
    it "Should work with arrays", ->
      _.pick({a:"a", b:"b", c:"c"}, ["a", "b"]).should.deep.equal({a:"a", b:"b"})

describe 'Game', ->
  alice    = null
  bob      = null
  game     = null

  beforeEach (done) ->
    alice = new User({name: "Alice"})
    bob   = new User({name: "Bob"})
    game  = new Game
      black: bob.id
      white: alice.id
      state: 'new'

    User.flush().
      then(-> Game.flush()).
      then(-> alice.save()).
      then(-> bob.save()).
      then(-> game.save()).
      then(-> done()).
      catch((err) -> done(err))

  describe '#find', ->
    it 'should find an existing game', ->
      Game.find(game.id).then (item) ->
        item.should.not.be.a 'string'
        expect(item).to.deep.equal game

    it 'should fail when a game doesn\'t exist', ->
      should_fail Game.find(new ObjectID().toHexString())

  describe '#render', ->
    it 'should show a game in the format expected', ->
      game.render().should.deep.equal
        id: game.id
        black: bob.id
        white: alice.id
        state: 'new'

  describe '#create', ->
    it 'should save a game to the database', ->
      Game.create(game).
        then((item) -> expect(item.id).to.not.equal game.id)

    describe "With a broken DB", ->
      beforeEach -> Model.DB = broken_db
      afterEach  -> Model.DB = good_db
      it 'should propagate database errors', ->
        should_fail Game.create(game)

  describe '#make', ->
    it 'should fail if black doesn\'t exist', ->
      should_fail Game.make(new ObjectID().toHexString(), bob.id)

    it 'should fail if white doesn\'t exist', ->
      should_fail Game.make(alice.id, new ObjectID().toHexString())

    it 'should fail if black and white are the same', ->
      should_fail Game.make(alice.id, alice.id)

    it 'should create a game in the "new" state', ->
      Game.make(alice.id, bob.id).then (new_game) ->
        expect(game.state).to.equal 'new'

    it 'should save the game to the database', (done) ->
      new_game = null
      Game.make(alice.id, bob.id).
        then((o) -> new_game = o; Game.find new_game.id).
        then((found_game) -> expect(found_game).to.deep.equal new_game)

    describe "With a broken DB", ->
      beforeEach -> Model.DB = broken_db
      afterEach  -> Model.DB = good_db
      it 'should propagate database errors', ->
        should_fail Game.make(alice.id, bob.id)