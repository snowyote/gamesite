User = require './user'

module.exports = (req, res, next) ->
  req.userId = req.signedCookies.userId
  user = null

  mkuser = (next) ->
    User.create {name:"Friendly Newbie"}, (err, _user) ->
      return next(err) if err?
      user = _user
      req.userId = user.id
      res.cookie 'userId', user.id, { signed: true }
      next(null, user)

  req.user = (cb) ->
    return cb(null, user) if user
    User.find req.userId, (err, _user) ->
      return cb(err) if err?
      user = _user
      return cb(err, _user) if _user?
      mkuser(cb)

  return next() if req.userId?

  mkuser(next)