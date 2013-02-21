lib = '../../../lib'
ObjectID        = require('mongodb').ObjectID
UsersController = require("#{lib}/routes/api/users_controller.coffee")
Q               = require 'q'
Model           = require "#{lib}/model"
User            = require "#{lib}/user"
app             = require "#{lib}/server"
Config          = require('config').Top
_               = require 'underscore'

setup_db (err, db) -> Model.DB = db

describe 'UsersController', ->
  [alice, bob] = []

  cookieForId = (id) ->
    id = String(id)
    rv = null
    fakeResponse =
      cookie: app.response.cookie
      req: { secret: Config.SiteSecret }
      set: (_, cookie) -> rv = cookie
    fakeResponse.cookie('userId', id, { signed: true })
    rv


  beforeEach (done) ->
    alice = new User({name: "Alice", email: "alice@sports.edu", online: true})
    bob   = new User({name: "Bob", email: "bob@winchestermysteryhouse.mil"})
    Q.all([User.flush()]).
      then(-> Q.all _.map([alice, bob], (x) -> x.save())).
      then(-> done()).
      catch((err) -> done(err))

  describe '#index', ->
    it 'should list offline users', (done) ->
      request(app)
        .get('/api/users?status=offline')
        .set("Cookie", cookieForId(alice.id))
        .expect(200, [bob.render()])
        .end(done)

    it 'should list online users', (done) ->
      request(app)
        .get('/api/users?status=online')
        .set("Cookie", cookieForId(alice.id))
        .expect(200, [alice.render()])
        .end(done)

    it 'should require a legit query', (done) ->
      request(app)
        .get('/api/users?status=bargle')
        .set("Cookie", cookieForId(alice.id))
        .expect(406)
        .end(done)

  describe '#show', ->
    it 'should show a user', (done) ->
      request(app)
        .get("/api/users/#{alice.id}")
        .set("Cookie", cookieForId(alice.id))
        .expect(200, alice.render())
        .end(done)

    it 'should 404 on a user that doesn\'t exist', (done) ->
      request(app)
        .get("/api/users/#{new ObjectID().toHexString()}")
        .set("Cookie", cookieForId(alice.id))
        .expect(404)
        .end(done)

  describe '#me', ->
    it 'should show a user themself', (done) ->
      request(app)
        .get('/api/users/me')
        .set("Cookie", cookieForId(alice.id))
        .expect(200, alice.render_for_self())
        .end(done)

  describe '#update', ->
    it 'should update a user', (done) ->
      request(app)
        .put("/api/users/#{alice.id}")
        .set("Cookie", cookieForId(alice.id))
        .send({name: "Alicia"})
        .expect(_.extend(alice.render(), {name: "Alicia"}))
        .end(done)
