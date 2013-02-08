express     = require('express')
app         = express()
server      = require('http').createServer(app)
io          = require('socket.io').listen(server)
_           = require('underscore')
argv        = require('optimist').argv
MongoClient = require('mongodb').MongoClient
Config      = require('config')

# TODO use promises instead
db = null
MongoClient.connect Config.Database, (err, database) ->
  throw err if err
  db = database

server.listen(argv.port||3000)
app.use(express.static(__dirname + '/static'))

# routing
app.get '/games', (req, res) ->
  db.collection('games').find {}, (err, result) ->
    games = for game in result
      game_id: game.game_id
      state:   game.state
      black:   game.black
      white:   game.white
    res.send games
