ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
Q = require 'q'

module.exports = class Model
  @DB: null

  @collection: ->
    Model.DB.collection(@collection_name)

  attributes: (document = this) ->
    _.pick(document, @constructor.attrs)

  constructor: (document) ->
    _.extend this, @attributes(document)
    @id = (document._id || new ObjectID()).toHexString()

  save: ->
    Q.ninvoke @constructor.collection(), 'save', @document()

  document: ->
    _.extend {_id: new ObjectID(@id)}, @attributes()

  render: ->
    _.extend {id: @id}, @attributes()

  @flush: ->
    Q.ninvoke @collection(), 'remove', {}

  @pfind: (id_or_query) ->
    deferred = Q.defer()

    mk = (item) => new this(item)
    if typeof(id_or_query) == "string"
      @collection().findOne {_id: new ObjectID(id_or_query)}, (err, item) ->
        return deferred.reject(err || "Couldn't find id") if (err? || !item?)
        deferred.resolve mk(item)
    else
      @collection().find id_or_query, (err, cursor) ->
        cursor.toArray (err, items) ->
          return deferred.reject(err) if err?
          deferred.resolve _.map(items, (item) -> mk(item))

    return deferred.promise

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
    model.save().then((-> next(null, model)), ((err) -> next(err)))

  @update: (id, attrs, next) ->
    update = { $set: attrs }
    @collection().update {_id: ObjectID(id)}, update, {upsert: false, safe: true}, (err, num_updated) ->
      return next(err) if err?
      return next("Couldn't find #{@collection_name}/#{id} to update") if num_updated != 1
      next(null)

  @delete: (id, next) ->
    @collection().remove {_id: ObjectID(id)}, next