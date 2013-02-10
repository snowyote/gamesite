ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
Seq = require 'seq'

render_user = (user) ->
  user_id: user._id.toHexString()
  name:    user.name

render_game = (game) ->
  game_id: game._id.toHexString()
  state:   game.state
  black:   game.black
  white:   game.white

find_user = (db, id, next) ->
  db.collection('users').findOne {_id: ObjectID(id)}, next

make_game = (db, attrs, next) ->
  game = _.extend({_id: new ObjectID}, attrs)
  db.collection('games').save game, (err, item) -> next err, game

create_game = (db, req, black, white, next) ->
  games = db.collection('games')

  # validate input
  if black == white
    return next("Don't play with yourself")

  Seq()
    .par_((next) -> find_user db, black, next)
    .par_((next) -> find_user db, white, next)
    .seq_((_, black_user, white_user) ->
      return next("Couldn't find black player") unless black_user?
      return next("Couldn't find white player") unless white_user?

      game =
        state: 'new'
        black: black
        white: white

      make_game db, game, next
      )
    .catch((err) ->
      next err, null)


module.exports = (app, db) ->
  app.get '/api/games/:id', (req, res) ->
    db.collection('games').find {_id: ObjectID(req.params.id)}, (err, result) ->
      res.send render_game(game)

  app.post '/api/games/versus/:other', (req, res) ->
    create_game db, req, req.userId, req.params.other, (err, game) ->
      if err
        res.status(406).send {error: err}
      else
        res.status(200).send render_game(game)

  app.get '/api/users/:id', (req, res) ->
    db.collection('users').find {_id: ObjectID(req.params.id)}, (err, result) ->
      res.send render_user(user)
