_ = require 'underscore'
Util = require '../../util'

module.exports = (db) ->
  index: (req, res) ->
    query = switch req.query.status
      when 'online' then {online: true}
      when 'offline' then {$or:[{online:{$exists:false}},{online:false}]}
      else 'barf'

    return res.status(406).send "Unsupported status query" if query == 'barf'

    db.collection('users').find query, (err, cursor) ->
      if err
        res.status(500).send {error: err}
      else
        cursor.toArray (err, users) ->
          res.status(200).send(Util.render_user(user) for user in users)

  show: (req, res) ->
    Util.find_user db, req.params.id, (err, user) ->
      if err
        res.status(500).send {error: err}
      else unless user?
        res.send(404)
      else
        res.status(200).send Util.render_user(user)

  me: (req, res) ->
    req.user (err, user) ->
      return res.status(500).send {error: err} if err?
      res.status(200).send Util.render_user(user)

  update: (req, res) ->
    if req.params.id != req.userId
      return res.status(500).send {error: "You can only modify yourself"}

    attrs = _.pick req.body, 'name', 'email'
    Util.update_user db, req.params.id, attrs, (err, user) ->
      if err
        res.status(500).send {error: err}
      else
        res.send(200)