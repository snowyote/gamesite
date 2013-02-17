_ = require 'underscore'
User = require '../../user'

module.exports =
  index: (req, res) ->
    query = switch req.query.status
      when 'online' then {online: true}
      when 'offline' then {$or:[{online:{$exists:false}},{online:false}]}
      else 'barf'

    return res.status(406).send "Unsupported status query" if query == 'barf'

    User.find query, (err, users) ->
      if err
        res.status(500).send {error: err}
      else
        res.status(200).send(user.render() for user in users)

  show: (req, res) ->
    User.find req.params.id, (err, user) ->
      if err
        res.status(500).send {error: err}
      else unless user?
        res.send(404)
      else
        res.status(200).send user.render()

  me: (req, res) ->
    req.user (err, user) ->
      return res.status(500).send {error: err} if err?
      res.status(200).send user.render()

  update: (req, res) ->
    if req.params.id != req.userId
      return res.status(500).send {error: "You can only modify yourself"}

    attrs = _.pick req.body, 'name', 'email'
    User.update req.params.id, attrs, (err, user) ->
      if err
        res.status(500).send {error: err}
      else
        res.send(200)