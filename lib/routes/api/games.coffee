Util = require '../../util'

module.exports = (db) ->
  index: (req, res) ->
    query = {state: req.query.state, $or:[{black:req.userId},{white:req.userId}]}
    query = {$or:[{black:req.userId},{white:req.userId}]}
    db.collection('games').find query, (err, cursor) ->
      if err
        res.status(500).send {error: err}
      else
        cursor.toArray (err, games) ->
          res.status(200).send(Util.render_game(game) for game in games)

  show: (req, res) ->
    Util.find_game db, req.params.id, (err, game) ->
      if err
        res.status(500).send {error: err}
      else unless game?
        res.send(404)
      else
        res.status(200).send Util.render_game(game)

  versus: (req, res) ->
    Util.create_game db, req, req.userId, req.params.other, (err, game) ->
      if err
        res.status(406).send {error: err}
      else
        res.status(200).send Util.render_game(game)