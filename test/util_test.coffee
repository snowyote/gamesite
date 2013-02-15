Util        = require '../lib/util'

ObjectID    = require('mongodb').ObjectID
_           = require 'underscore'
Seq         = require 'seq'

setup_db()

describe 'Util', ->
  alice    = null
  alice_id = null
  bob      = null
  bob_id   = null
  game     = null
  game_id  = null

  beforeEach (done) ->
    alice    = {name: "Alice", _id: new ObjectID}
    alice_id = alice._id.toHexString()

    bob      = {name: "Bob", _id: new ObjectID}
    bob_id = bob._id.toHexString()

    game     =
      _id: new ObjectID
      white: bob_id
      black: alice_id
      state: 'new'
    game_id = game._id.toHexString()

    Seq()
      .seq_((next) -> db.collection('users').remove {}, next)
      .seq_((next) -> db.collection('games').remove {}, next)
      .seq_((next) -> db.collection('users').save alice, next)
      .seq_((next) -> db.collection('users').save bob, next)
      .seq_((next) -> db.collection('games').save game, next)
      .seq_((next) -> done())
      .catch((err) -> done err, null)

  describe 'find_user', ->
    it 'should find an existing user', (done) ->
      Util.find_user db, alice_id, (err, user) ->
        expect(err).to.be.null
        expect(user).to.not.be.null
        expect(user).to.deep.equal alice
        done()
    it 'should return null when a user doesn\'t exist', (done) ->
      Util.find_user db, new ObjectID().toHexString(), (err, user) ->
        expect(err).to.be.null
        expect(user).to.be.null
        done()

  describe 'update_user', ->
    it 'should update an existing user', (done) ->
      Util.update_user db, bob_id, {name: "Bobular"}, (err) ->
        expect(err).to.be.null
        Util.find_user db, bob_id, (err, user) ->
          expect(err).to.be.null
          expect(user.name).to.equal 'Bobular'
          done()
    it 'should raise an error if the user doesn\'t exist', (done) ->
      dudeid = new ObjectID()
      Util.update_user db, dudeid.toHexString(), {name: "Dude"}, (err, rv) ->
        expect(err).to.not.be.null
        done()

  describe 'render_user', ->
    it 'should show a user in the format expected', ->
      sporf =
        _id: new ObjectID
        name: "Sporf"
        email: "hoo@hey.edu"
        private: "crap"

      Util.render_user(sporf).should.deep.equal
        user_id: sporf._id.toHexString()
        name: "Sporf"
        email: "hoo@hey.edu"

  describe 'find_game', ->
    it 'should find an existing game', (done) ->
      Util.find_game db, game_id, (err, item) ->
        expect(err).to.be.null
        expect(item).to.deep.equal game
        done()
    it 'should return null when a game doesn\'t exist', (done) ->
      Util.find_game db, new ObjectID().toHexString(), (err, item) ->
        expect(err).to.be.null
        expect(item).to.be.null
        done()

  describe 'render_game', ->
    it 'should show a game in the format expected', ->
      Util.render_game(game).should.deep.equal
        game_id: game_id
        white: bob_id
        black: alice_id
        state: 'new'

  describe 'make_game', ->
    it 'should save a game to the database', (done) ->
      Util.make_game db, game, (err, item) ->
        expect(err).to.be.null
        expect(item._id.toHexString()).to.not.equal game_id
        done()

    it 'should propagate database errors', (done) ->
      Util.make_game broken_db, game, (err, item) ->
        expect(err).to.not.be.null
        done()

  describe 'create_game', ->
    it 'should fail if black doesn\'t exist', (done) ->
      Util.create_game db, new ObjectID().toHexString(), bob_id, (err, item) ->
        expect(err).to.not.be.null
        expect(item).to.not.be.ok
        done()

    it 'should fail if white doesn\'t exist', (done) ->
      Util.create_game db, alice_id, new ObjectID().toHexString(), (err, item) ->
        expect(err).to.not.be.null
        expect(item).to.not.be.ok
        done()

    it 'should fail if black and white are the same', (done) ->
      Util.create_game db, alice_id, alice_id, (err, item) ->
        expect(err).to.not.be.null
        expect(item).to.not.be.ok
        done()

    it 'should create a game in the "new" state', (done) ->
      Util.create_game db, alice_id, bob_id, (err, item) ->
        expect(err).to.be.null
        expect(game.state).to.equal 'new'
        done()

    it 'should save the game to the database', (done) ->
      Util.create_game db, alice_id, bob_id, (err, item) ->
        expect(err).to.be.null
        Util.find_game db, item._id.toHexString(), (err, found_game) ->
          expect(err).to.be.null
          expect(found_game).to.deep.equal item
          done()

    it 'should propagate database errors', (done) ->
      Util.create_game broken_db, alice_id, bob_id, (err, item) ->
        expect(err).to.not.be.null
        done()
