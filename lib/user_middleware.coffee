User = require './user'

module.exports = (req, res, next) ->
  req.userId = req.signedCookies.userId
  user = null

  mkuser = (next) ->
    User.create({name:"Friendly Newbie"}).then((_user) ->
      user = _user
      req.userId = user.id
      res.cookie 'userId', user.id, { signed: true }
      next(null, user)).
      fail((err) -> next(err))

  req.user = (cb) ->
    return cb(null, user) if user
    User.find(req.userId).
      then((_user) ->
        if _user?
          cb(null, user = _user)
        else
          mkuser(cb)
      ).fail((err) -> cb(err))

  return next() if req.userId?

  mkuser(next)