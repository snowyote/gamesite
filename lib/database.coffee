mongodb     = require 'mongodb'
MongoClient = mongodb.MongoClient
Server      = mongodb.Server
Config      = require('config').Top

module.exports =
  db: null

  client: null

  open: (next) ->
    # @TODO we can have two opens in flight and that sucks
    # I should use promises
    return next(null, @db) if @db?
    server = new Server(Config.Database.Host, Config.Database.Port, Config.Database.Options)
    @client = new MongoClient(server)
    @client.open (err) =>
      return next(err) if err?
      @db = @client.db(Config.Database.DB)
      next(null, @db)

  close: (next) ->
    return next(null) unless @db?
    @db = null
    @client.close next