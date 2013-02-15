express     = require('express')
app         = express()
server      = require('http').createServer(app)
io          = require('socket.io').listen(server)
_           = require('underscore')
argv        = require('optimist').argv
Config      = require('config').Top
Seq         = require('seq')
database    = require('./lib/database')

startServer = (db) ->
  port = argv.port || 3000
  server.listen port
  console.log "Listening on port #{port}"

  # Cookies all around, boys
  app.use(express.cookieParser(Config.SiteSecret))
  app.use(express.bodyParser())

  # this is a shitty pattern.  I can do better than this.
  app.use(require('./lib/user_middleware')(db))

  # routing for the API
  require('./lib/routes')(app, db)

  # otherwise, serve static files
  app.use(express.static(__dirname + '/static'))

database.open().then(startServer)
