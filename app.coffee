express = require('express')
app     = express()
server  = require('http').createServer(app)
io      = require('socket.io').listen(server)
_       = require 'underscore'

server.listen 3000
app.use(express.static(__dirname + '/static'));
