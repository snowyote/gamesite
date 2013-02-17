module.exports = (app) ->
  api = require('./api')

  app.get '/api/games',                (req, res) ->
    new api.GamesController(req, res).index()
  app.get  '/api/games/:id',           (req, res) ->
    new api.GamesController(req, res).show()
  app.post '/api/games/versus/:other', (req, res) ->
    new api.GamesController(req, res).versus()


  app.get  '/api/users',               (req, res) ->
    new api.UsersController(req, res).index()
  app.get  '/api/users/me',            (req, res) ->
    new api.UsersController(req, res).me()
  app.get  '/api/users/:id',           (req, res) ->
    new api.UsersController(req, res).show()
  app.put  '/api/users/:id',           (req, res) ->
    new api.UsersController(req, res).update()
