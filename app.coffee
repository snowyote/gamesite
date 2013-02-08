express     = require('express')
app         = express()
server      = require('http').createServer(app)
io          = require('socket.io').listen(server)
_           = require('underscore')
argv        = require('optimist').argv
MongoClient = require('mongodb').MongoClient
Config      = require('config').Top
Seq         = require('seq')

startMongo  = ->
  MongoClient.connect Config.Database, this

startServer = (db) ->
  port = argv.port || 3000
  server.listen port
  console.log "Listening on port #{port}"

  app.use(express.cookieParser(Config.SiteSecret))
  app.use(require('./lib/user_middleware')(db.collection('users')))
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

  app.get '/', (req, res) ->
    res.send { oh: "hai" }

Seq()
  .seq(startMongo)
  .seq(startServer)
