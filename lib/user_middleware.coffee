ObjectID = require('mongodb').ObjectID

module.exports = (users) ->
  (req, res, next) ->
    userId = req.signedCookies.userId
    user = null

    req.user = (cb) ->
      return cb(null, user) if user
      users.findOne {_id: ObjectId(userId)}, (err, item) ->
        user = item
        cb(err, item)

    return next() if userId?

    oid = new ObjectID()
    user = {name:"Friendly Newbie", _id:oid}
    users.save user, (err, item) ->
      throw err if err
      res.cookie 'userId', oid.toHexString(), { signed: true }
      next()
