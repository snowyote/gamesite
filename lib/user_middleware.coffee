ObjectID = require('mongodb').ObjectID
Util = require './util'

module.exports = (db) ->
  (req, res, next) ->
    req.userId = req.signedCookies.userId
    user = null

    req.user = (cb) ->
      return cb(null, user) if user
      Util.find_user req.userId, (err, item) ->
        user = item
        cb(err, item)

    return next() if req.userId?

    Util.make_user db, {name:"Friendly Newbie"}, (err, user) ->
      throw err if err
      res.cookie 'userId', (req.userId = user._id.toHexString()), { signed: true }
      next()
