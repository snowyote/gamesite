User               = require '../../user'
ResourceController = require '../../resource_controller'

module.exports = class UsersController extends ResourceController
  resource_class: User
  index_query: ->
    return switch @req.query.status
      when 'online' then {online: true}
      when 'offline' then {$or:[{online:{$exists:false}},{online:false}]}
  me: ->
    @req.user (err, user) ->
      @respond err, -> user.render()
  update: ->
    return super() if @req.params.id == @req.userId
    @res.status(500).send {error: "You can only modify yourself"}
