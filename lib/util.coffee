ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
Seq = require 'seq'

module.exports =
  find_user: (db, id, next) ->
    db.collection('users').findOne {_id: ObjectID(id)}, next

  make_user: (db, attrs, next) ->
    user = _.extend({_id: new ObjectID}, attrs)
    db.collection('users').save user, (err, item) -> next err, user

  update_user: (db, id, attrs, next) ->
    update = { $set: attrs }
    db.collection('users').update {_id: ObjectID(id)}, update, next

  render_user: (user) ->
    user_id: user._id.toHexString()
    name:    user.name
    email:   user.email

  find_game: (db, id, next) ->
    db.collection('games').findOne {_id: ObjectID(id)}, next

  render_game: (game) ->
    game_id: game._id.toHexString()
    state:   game.state
    black:   game.black
    white:   game.white

  make_game: (db, attrs, next) ->
    game = _.extend({_id: new ObjectID}, attrs)
    db.collection('games').save game, (err, item) -> next err, game

  create_game: (db, req, black, white, next) ->
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
