ObjectID = require('mongodb').ObjectID

module.exports = (users) ->
  (req, res, next) ->
    req.userId = req.signedCookies.userId
    user = null

    req.user = (cb) ->
      return cb(null, user) if user
      users.findOne {_id: ObjectID(req.userId)}, (err, item) ->
        user = item
        cb(err, item)

    return next() if req.userId?

    oid = new ObjectID()
    user = {name:"Friendly Newbie", _id:oid}
    users.save user, (err, item) ->
      throw err if err
      res.cookie 'userId', (req.userId = oid.toHexString()), { signed: true }
      next()
