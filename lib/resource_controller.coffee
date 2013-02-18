_ = require 'underscore'

module.exports = class ResourceController
  constructor: (@req, @res) ->

  index: ->
    query = @index_query()
    return @res.status(406).send "Unsupported query" unless query?
    @resource_class.find query, (err, items) =>
      @respond err, -> (item.render() for item in items)

  show: ->
    @resource_class.find @req.params.id, (err, item) =>
      @respond err, -> item.render()

  update: ->
    update = { $set: @update_filter(@req.body) }
    @resource_class.update @req.body.id, update, (err, item) =>
      @respond err, -> item.render()

  destroy: ->
    @resource_class.delete @respond_empty

  create: ->
    @resource_class.create @req.body, (err, item) =>
      @respond err, -> item.render()

  respond: (err, rv_cb) ->
    return @res.status(500).send {error: err} if err

    rv = rv_cb()
    unless rv?
      @res.send(404)
    else
      @res.status(200).send(rv)

  respond_empty: (err) ->
    if err
      @res.status(500).send {error: err}
    else
      @res.status(200).send()

  update_filter: (doc) ->
    _.pick doc, @resource_class.attrs

  index_query: -> {}