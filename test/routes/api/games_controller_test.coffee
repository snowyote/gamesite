lib = '../../../lib'
GamesController = require("#{lib}/routes/api/games_controller.coffee")
Seq             = require "seq"
Model           = require "#{lib}/model"
User            = require "#{lib}/user"
Game            = require "#{lib}/game"
app             = require "#{lib}/server"
Config = require('config').Top
_ = require 'underscore'

setup_db (err, db) -> Model.DB = db

describe 'GamesController', ->
  [alice, bob, frank, ab_game, bf_game] = []

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
    alice = new User({name: "Alice"})
    bob   = new User({name: "Bob"})
    frank = new User({name: "Frank"})

    ab_game = new Game
      black: bob.id
      white: alice.id
      state: 'new'

    bf_game = new Game
      black: bob.id
      white: frank.id
      state: 'new'

    Seq()
      .seq_((next) -> User.collection().remove {}, next)
      .seq_((next) -> Game.collection().remove {}, next)
      .set([alice, bob, frank, ab_game, bf_game])
      .parEach((item, index) -> item.save this)
      .seq_((next) -> done())
      .catch((err) -> done err, null)

  describe '#index', ->
    it 'should list games of the queried state', (done) ->
      request(app)
        .get('/api/games?state=new')
        .set("Cookie", cookieForId(alice.id))
        .expect(200)
        .expect([ab_game.render()])
        .end(done)

    it 'should not list games not of the queried state', ->
    it 'should 500 on a db error', ->
  describe '#show', ->
    it 'should show a game', ->
    it 'should 404 on a game that doesn\'t exist', ->
    it 'should 500 on a db error', ->
  describe '#versus', ->
    it 'should create a game', ->
    it 'should 406 on invalid params', ->
