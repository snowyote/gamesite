ObjectID = require('mongodb').ObjectID
_ = require 'underscore'

module.exports = class Model
  @DB: null

  @collection: ->
    Model.DB.collection(@collection_name)

  attributes: (document = this) ->
    _.pick(document, @constructor.attrs)

  constructor: (document) ->
    _.extend this, @attributes(document)
    @id = (document._id || new ObjectID()).toHexString()

  save: (next) ->
    @constructor.collection().save @document(), next

  document: ->
    _.extend {_id: new ObjectID(@id)}, @attributes()

  render: ->
    _.extend {id: @id}, @attributes()

  @find: (id_or_query, next) ->
    mk = (item) => new this(item)
    if typeof(id_or_query) == "string"
      @collection().findOne {_id: new ObjectID(id_or_query)}, (err, item) ->
        return next(err, null) if (err? || !item?)
        next err, mk(item)
    else
      @collection().find id_or_query, (err, cursor) ->
        cursor.toArray (err, items) ->
          next err, _.map(items, (item) -> mk(item))

  @create: (attrs, next) ->
    model = new this(_.extend {}, attrs,  {_id: new ObjectID()})
    model.save (err, _) ->
      return next(err) if err?
      next(null, model)

  @update: (id, attrs, next) ->
    update = { $set: attrs }
    @collection().update {_id: ObjectID(id)}, update, {upsert: false, safe: true}, (err, num_updated) ->
      return next(err) if err?
      return next("Couldn't find #{@collection_name}/#{id} to update") if num_updated != 1
      next(null)

  @delete: (id, next) ->
    @collection().remove {_id: ObjectID(id)}, next