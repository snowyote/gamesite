Game               = require '../../game'
ResourceController = require '../../resource_controller'

module.exports = class GamesController extends ResourceController
  resource_class: Game
  index_query: -> {$and:[{state:@req.query.state},{$or:[{black:@req.userId},{white:@req.userId}]}]}
  versus: ->
    Game.make(@req.userId, @req.params.other).
      then((game) => @res.send game.render()).
      fail((err) => @res.send 500)
