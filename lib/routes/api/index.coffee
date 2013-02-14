module.exports = (db) ->
  games: require('./games')(db)
  users: require('./users')(db)
