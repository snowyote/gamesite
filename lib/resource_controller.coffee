_ = require 'underscore'

module.exports = class ResourceController
  constructor: (@req, @res) ->

  index: ->
    query = @index_query()
    return res.status(406).send "Unsupported query" unless query?
    @resource_class.find query, (err, items) ->
      @respond err, -> (item.render() for item in items)

  show: (req, res) ->
    @resource_class.find req.params.id, (err, item) ->
      @respond err, -> item.render()

  update: (req, res) ->
    update = { $set: @update_filter(req.body) }
    @resource_class.update req.body.id, update, (err, item) ->
      @respond err, -> item.render()

  destroy: (req, res) ->
    @resource_class.delete @respond_empty

  create: (req, res) ->
    @resource_class.create req.body, (err, item) ->
      @respond err, -> item.render()

  respond: (err, rv_cb) ->
    if err
      res.status(500).send {error: err}
    else unless rv?
      res.send(404)
    else
      res.status(200).send(rv_cb())

  respond_empty: (err) ->
    if err
      res.status(500).send {error: err}
    else
      res.status(200).send()

  update_filter: (doc) ->
    _.pick doc, @resource_class.attrs

  index_query: -> {}