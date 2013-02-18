express = require('express')
app     = express()
Config  = require('config').Top
Model   = require('./model')

app.use(express.logger()) if Config.UseLogger
app.use(express.methodOverride())

app.use (req, res, next) ->
  res.header('Access-Control-Allow-Origin', "*");
  res.header('Access-Control-Allow-Methods', 'OPTIONS,GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type,Accept,Origin,X-Requested-With');
  res.header('Access-Control-Max-Age', 60 * 60 * 24 * 365);
  next()

# Cookies all around, boys
app.use(express.cookieParser(Config.SiteSecret))
app.use(express.bodyParser())

# users for every request
app.use(require('./user_middleware'))

# routing for the API
require('./routes')(app)

# otherwise, serve static files
app.use(express.static(__dirname + '/static'))

module.exports = app
