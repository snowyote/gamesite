ObjectID = require('mongodb').ObjectID
Seq = require 'seq'

render_user = (user) ->
  user_id: user._id.toHexString()
  name:    user.name

render_game = (game) ->
  game_id: game._id.toHexString()
  state:   game.state
  black:   render_user(game.black)
  white:   render_user(game.white)

create_game = (db, req, black, white, cb) ->
  userId = req.userId
  users = db.collection('users')
  games = db.collection('games')
  Seq()
    .seq_((next) ->
      if black == white
        return next("Don't play with yourself")
      if black != userId && white != userId
        return next("You can't arrange a game between two other players")
      next())
    .par_((next) ->
      users.findOne {_id: ObjectID(black||userId)}, next)
    .par_((next) ->
      users.findOne {_id: ObjectID(white||userId)}, next)
    .seq_((next, black, white) ->
      return next("Couldn't find black player") unless black?
      return next("Couldn't find white player") unless white?
      oid = new ObjectID
      game =
        _id:   oid
        state: 'new'
        black: black
        white: white
      users.save game, (err, item) ->
        next err, game)
    .seq_((next, game) ->
      cb null, game)
    .catch((err) ->
      cb err, null)


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
