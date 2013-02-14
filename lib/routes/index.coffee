module.exports = (app, db) ->
  api = require('./api')(db)

  app.get  '/api/games',               api.games.index
  app.get  '/api/games/:id',           api.games.show
  app.post '/api/games/versus/:other', api.games.versus
  app.get  '/api/users',               api.users.index
  app.get  '/api/users/:id',           api.users.show
  app.put  '/api/users/:id',           api.users.update
