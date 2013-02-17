ObjectID    = require('mongodb').ObjectID
_           = require 'underscore'
Seq         = require 'seq'
User        = require '../lib/user'
Game        = require '../lib/game'

good_db = null
Model = require '../lib/model'
setup_db((err, db) -> good_db = Model.DB = db)

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

    Seq()
      .seq_((next) -> User.collection().remove {}, next)
      .seq_((next) -> Game.collection().remove {}, next)
      .seq_((next) -> alice.save next)
      .seq_((next) -> bob.save next)
      .seq_((next) -> game.save next)
      .seq_((next) -> done())
      .catch((err) -> done err, null)

  describe '#find', ->
    it 'should find an existing game', (done) ->
      Game.find game.id, (err, item) ->
        expect(err).to.be.null
        item.should.not.be.a 'string'
        expect(item).to.deep.equal game
        done()
    it 'should return null when a game doesn\'t exist', (done) ->
      Game.find new ObjectID().toHexString(), (err, item) ->
        expect(err).to.be.null
        expect(item).to.be.null
        done()

  describe '#render', ->
    it 'should show a game in the format expected', ->
      game.render().should.deep.equal
        id: game.id
        black: bob.id
        white: alice.id
        state: 'new'

  describe '#create', ->
    it 'should save a game to the database', (done) ->
      Game.create game, (err, item) ->
        expect(err).to.be.null
        expect(item.id).to.not.equal game.id
        done()

    # it 'should propagate database errors', (done) ->
    #   beforeEach -> Model.DB = broken_db
    #   afterEach  -> Model.DB = good_db
    #   Game.create game, (err, item) ->
    #     expect(err).to.not.be.null
    #     done()

  describe '#make', ->
    it 'should fail if black doesn\'t exist', (done) ->
      Game.make new ObjectID().toHexString(), bob.id, (err, new_game) ->
        expect(err).to.not.be.null
        expect(new_game).to.not.be.ok
        done()

    it 'should fail if white doesn\'t exist', (done) ->
      Game.make alice.id, new ObjectID().toHexString(), (err, new_game) ->
        expect(err).to.not.be.null
        expect(new_game).to.not.be.ok
        done()

    it 'should fail if black and white are the same', (done) ->
      Game.make alice.id, alice.id, (err, new_game) ->
        expect(err).to.not.be.null
        expect(new_game).to.not.be.ok
        done()

    it 'should create a game in the "new" state', (done) ->
      Game.make alice.id, bob.id, (err, new_game) ->
        expect(err).to.be.null
        expect(game.attrs.state).to.equal 'new'
        done()

    it 'should save the game to the database', (done) ->
      Game.make alice.id, bob.id, (err, new_game) ->
        expect(err).to.be.null
        Game.find new_game.id, (err, found_game) ->
          expect(err).to.be.null
          expect(found_game).to.deep.equal new_game
          done()

    # it 'should propagate database errors', (done) ->
    #   beforeEach -> Model.DB = broken_db
    #   afterEach  -> Model.DB = good_db
    #   Game.make game, (err, new_game) ->
    #     expect(err).to.not.be.null
    #     done()
