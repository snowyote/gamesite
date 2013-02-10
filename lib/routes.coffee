ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
Seq = require 'seq'

find_user = (db, id, next) ->
  db.collection('users').findOne {_id: ObjectID(id)}, next

update_user = (db, id, attrs, next) ->
  update = { $set: attrs }
  db.collection('users').update {_id: ObjectID(id)}, update, next

render_user = (user) ->
  user_id: user._id.toHexString()
  name:    user.name
  email:   user.email

find_game = (db, id, next) ->
  db.collection('games').findOne {_id: ObjectID(id)}, next

render_game = (game) ->
  game_id: game._id.toHexString()
  state:   game.state
  black:   game.black
  white:   game.white

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
    find_game db, req.params.id, (err, game) ->
      if err
        res.status(500).send {error: err}
      else unless game?
        res.status(404)
      else
        res.status(200).send render_game(game)

  app.post '/api/games/versus/:other', (req, res) ->
    create_game db, req, req.userId, req.params.other, (err, game) ->
      if err
        res.status(406).send {error: err}
      else
        res.status(200).send render_game(game)

  app.get '/api/users', (req, res) ->
    query = switch req.query.status
      when 'online' then {online: true}
      when 'offline' then {$or:[{online:{$exists:false}},{online:false}]}
      else 'barf'

    return res.status(406).send "Unsupported status query" if query == 'barf'

    db.collection('users').find query, (err, cursor) ->
      if err
        res.status(500).send {error: err}
      else
        res.status(200).send(render_user(user) for user in cursor)

  app.get '/api/users/:id', (req, res) ->
    find_user db, req.params.id, (err, user) ->
      if err
        res.status(500).send {error: err}
      else unless user?
        res.status(404)
      else
        res.status(200).send render_user(user)

  app.put '/api/users/:id', (req, res) ->
    if req.params.id != req.userId
      return res.status(500).send {error: "You can only modify yourself"}

    attrs = _.pick req.body, 'name', 'email'
    update_user db, req.params.id, attrs, (err, user) ->
      if err
        res.status(500).send {error: err}
      else
        res.send(200)
