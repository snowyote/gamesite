ObjectID = require('mongodb').ObjectID
Util = require './util'

module.exports = (db) ->
  (req, res, next) ->
    req.userId = req.signedCookies.userId
    user = null

    mkuser = (next) ->
      Util.make_user db, {name:"Friendly Newbie"}, (err, _user) ->
        return next(err) if err?
        user = _user
        req.userId = user._id.toHexString()
        res.cookie 'userId', req.userId, { signed: true }
        next(null, user)

    req.user = (cb) ->
      return cb(null, user) if user
      Util.find_user db, req.userId, (err, _user) ->
        return cb(err) if err?
        user = _user
        return cb(err, _user) if _user?
        mkuser(cb)

    return next() if req.userId?

    mkuser(next)