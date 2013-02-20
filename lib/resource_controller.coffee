_ = require 'underscore'

module.exports = class ResourceController
  constructor: (@req, @res) ->

  index: ->
    query = @index_query()
    return @res.status(406).send "Unsupported query" unless query?
    @resource_class.find(query).
      then((items) => @res.send (item.render() for item in items)).
      fail((err) => @res.send(500, {error: err.message}))

  show: ->
    @resource_class.find(@req.params.id).
      then((item) => @res.send item.render()).
      fail((err) => @res.send 404)

  update: ->
    update = { $set: @update_filter(@req.body) }
    @resource_class.update(@req.body.id, update).
      then((item) => @res.send item.render()).
      fail((err) => @res.send 500, {error: err.message})

  destroy: ->
    @resource_class.delete(@req.params.id).
      then(=> @res.send 200).
      fail(=> @res.send 406)

  create: ->
    @resource_class.create(@req.body).
      then((item) => @res.send 200, item.render()).
      fail((err) => @res.send 404)

  respond: (err, rv_cb) ->
    return @res.send(500, {error: err}) if err

    rv = rv_cb()
    unless rv?
      @res.send 404
    else
      @res.send 200, rv

  respond_empty: (err) ->
    if err
      @res.send 500, {error: err}
    else
      @res.send 200

  update_filter: (doc) ->
    _.pick doc, @resource_class.attrs

  index_query: -> {}