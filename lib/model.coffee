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
    Q.ninvoke @constructor.collection(), 'save', @document(), {safe:true}

  document: ->
    _.extend {_id: new ObjectID(@id)}, @attributes()

  render: ->
    _.extend {id: @id}, @attributes()

  @flush: ->
    Q.ninvoke @collection(), 'remove', {}, {safe: true}

  @find: (id_or_query) ->
    if typeof(id_or_query) == "string"
      Q.fcall(-> {_id: new ObjectID(id_or_query)}).
        then((id) => Q.ninvoke(@collection(), 'findOne', id)).
        then((item) => if item? then new this(item) else throw new Error "Couldn't find #{id_or_query}")
    else
      Q.ninvoke(@collection(), 'find', id_or_query).
        then((cursor) -> Q.ninvoke cursor, 'toArray').
        then((items) => _.map(items, (item) => new this(item)))

  @create: (attrs) ->
    model = new this(_.extend {}, attrs,  {_id: new ObjectID()})
    model.save().then -> model

  @update: (id, attrs) ->
    update = { $set: attrs }
    opts = {upsert: false, safe: true}
    Q.ninvoke(@collection(), 'update', {_id: ObjectID(id)}, update, opts).
      then(([num_updated, _...]) ->
        if num_updated != 1
          throw new Error("Couldn't find #{@collection_name}/#{id} to update"))

  @delete: (id) ->
    Q.ninvoke @collection().remove {_id: ObjectID(id)}