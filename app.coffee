argv     = require('optimist').argv
database = require './lib/database'
app      =
http     = require 'http'
socketio = require 'socket.io'
Model    = require './lib/model'

database.open().then (db) ->
  Model.DB = db

  port = argv.port || 3000
  console.log "Listening on port #{port}"
  server = http.createServer(require './lib/server')
  server.listen port

  io     = socketio.listen(server)
