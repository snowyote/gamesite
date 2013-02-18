Game               = require '../../game'
ResourceController = require '../../resource_controller'

module.exports = class GamesController extends ResourceController
  resource_class: Game
  index_query: -> {$and:[{state:@req.query.state},{$or:[{black:@req.userId},{white:@req.userId}]}]}
  versus: ->
    Game.make @req.userId, @req.params.other, (err, game) =>
      @respond err, -> game.render()
