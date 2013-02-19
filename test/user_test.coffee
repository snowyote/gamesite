ObjectID    = require('mongodb').ObjectID
_           = require 'underscore'
Q           = require 'q'
User        = require '../lib/user'

Model = require '../lib/model'
setup_db((err, db) -> Model.DB = db)

describe 'User', ->
  alice    = null
  bob      = null

  beforeEach (done) ->
    alice = new User({name: "Alice"})
    bob   = new User({name: "Bob"})

    User.flush().
      then(-> Q.all [alice.save(), bob.save()]).
      then(-> done()).
      catch((err) -> done(err))

  describe '#new', ->
    it 'should round-trip with #document', ->
      doc = {name: "Buddy"}
      _.omit(new User(doc).document(), '_id').should.deep.equal doc

  describe '#find', ->
    it 'should find an existing user', ->
      User.find(alice.id).then (user) ->
        expect(user).to.not.be.null
        expect(user).to.not.equal alice
        expect(user).to.deep.equal alice

    it 'should fail when a user doesn\'t exist', ->
      should_fail User.find(new ObjectID().toHexString())

  describe '#update', ->
    it 'should update an existing user', ->
      User.update(bob.id, {name: "Bobular"}).
        then(-> User.find(bob.id)).
        then((user) -> expect(user.name).to.equal 'Bobular')

    it 'should raise an error if the user doesn\'t exist', ->
      should_fail User.update(new ObjectID().toHexString(), {name: "Dude"})

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
