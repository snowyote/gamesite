ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
Seq = require 'seq'

render_user = (user) ->
  user_id: user._id.toHexString()
  name:    user.name

render_game = (game) ->
  game_id: game._id.toHexString()
  state:   game.state
  black:   render_user(game.black)
  white:   render_user(game.white)

find_user = (db, id, next) ->
  db.collection('users').findOne {_id: ObjectID(id)}, next

make_game = (db, attrs, next) ->
  game = _.extend({_id: new ObjectID}, attrs)
  db.collection('games').save game, (err, item) -> next err, game

create_game = (db, req, black, white, next) ->
  userId = req.userId
  games = db.collection('games')

  # validate input
  if black == white
    return next("Don't play with yourself")
  if black != userId && white != userId
    return next("You can't arrange a game between two other players")

  Seq()
    .par_((next) -> find_user db, black||userId, next)
    .par_((next) -> find_user db, white||userId, next)
    .seq_((_, black, white) ->
      return next("Couldn't find black player") unless black?
      return next("Couldn't find white player") unless white?

      game =
        state: 'new'
        black: black
        white: white

      make_game db, game, next
      )
    .catch((err) ->
      next err, null)


module.exports = (app, db) ->
  app.get '/api/games', (req, res) ->
    db.collection('games').find {}, (err, result) ->
      res.send(render_game(game) for game in result)

  app.post '/api/games/versus/:other', (req, res) ->
    create_game db, req, req.userId, req.params.other, (err, game) ->
      if err then res.status(500) else res.send render_game(game)

  app.get '/api/games/:id', (req, res) ->
    db.collection('games').find {_id: ObjectID(req.params.id)}, (err, result) ->
      res.send render_game(game)
