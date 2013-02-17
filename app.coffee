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

  app.use(express.logger())
  app.use(express.methodOverride())

  app.use (req, res, next) ->
    res.header('Access-Control-Allow-Origin', "localhost:#{port}");
    res.header('Access-Control-Allow-Methods', 'OPTIONS,GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type,Accept,Origin,X-Requested-With');
    res.header('Access-Control-Max-Age', 60 * 60 * 24 * 365);
    next()

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
