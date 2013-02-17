Game = require '../../game'

module.exports =
  index: (req, res) ->
    query = {state: req.query.state, $or:[{black:req.userId},{white:req.userId}]}
    query = {$or:[{black:req.userId},{white:req.userId}]}
    Game.find.find query, (err, games) ->
      if err
        res.status(500).send {error: err}
      else
        res.status(200).send(game.render() for game in games)

  show: (req, res) ->
    Game.find req.params.id, (err, game) ->
      if err
        res.status(500).send {error: err}
      else unless game?
        res.send(404)
      else
        res.status(200).send game.render()

  versus: (req, res) ->
    Game.make req.userId, req.params.other, (err, game) ->
      if err
        res.status(406).send {error: err}
      else
        res.status(200).send game.render()
