ObjectID    = require('mongodb').ObjectID
_           = require 'underscore'
Seq         = require 'seq'
User        = require '../lib/user'

Model = require '../lib/model'
setup_db((err, db) -> Model.DB = db)

describe 'User', ->
  alice    = null
  bob      = null

  beforeEach (done) ->
    alice = new User({name: "Alice"})
    bob   = new User({name: "Bob"})

    Seq()
      .seq_((next) -> User.collection().remove {}, next)
      .seq_((next) -> alice.save next)
      .seq_((next) -> bob.save next)
      .seq_((next) -> done())
      .catch((err) -> done err, null)

  describe '#new', ->
    it 'should round-trip with #document', ->
      doc = {name: "Buddy"}
      _.omit(new User(doc).document(), '_id').should.deep.equal doc

  describe '#find', ->
    it 'should find an existing user', (done) ->
      User.find alice.id, (err, user) ->
        expect(err).to.be.null
        expect(user).to.not.be.null
        expect(user).to.not.equal alice
        expect(user).to.deep.equal alice
        done()
    it 'should return null when a user doesn\'t exist', (done) ->
      User.find new ObjectID().toHexString(), (err, user) ->
        expect(err).to.be.null
        expect(user).to.be.null
        done()

  describe '#update', ->
    it 'should update an existing user', (done) ->
      User.update bob.id, {name: "Bobular"}, (err) ->
        expect(err).to.be.null
        User.find bob.id, (err, user) ->
          expect(err).to.be.null
          expect(user.name).to.equal 'Bobular'
          done()
    it 'should raise an error if the user doesn\'t exist', (done) ->
      dudeid = new ObjectID()
      User.update dudeid.toHexString(), {name: "Dude"}, (err, rv) ->
        expect(err).to.not.be.null
        done()

  describe '#render', ->
    it 'should show a user in the format expected', ->
      sporf = new User
        _id: new ObjectID
        name: "Sporf"
        email: "hoo@hey.edu"
        private: "crap"

      sporf.render().should.deep.equal
        id: sporf.id
        name: "Sporf"
        email: "hoo@hey.edu"
