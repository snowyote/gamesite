mongodb     = require 'mongodb'
MongoClient = mongodb.MongoClient
Server      = mongodb.Server
Config      = require('config').Top
Q           = require('q')

open_promise = null
close_promise = null
client = null

module.exports =
  open: ->
    return open_promise if open_promise?
    deferred = Q.defer()

    server = new Server(Config.Database.Host, Config.Database.Port, Config.Database.Options)
    client = new MongoClient(server)
    client.open (err) ->
      return deferred.reject(err) if err?
      resolution = client.db(Config.Database.DB)
      deferred.resolve resolution

    return (open_promise = deferred.promise)

  close: ->
    deferred = Q.defer()
    client.close -> deferred.resolve()
    return (close_promise = deferred.promise)
