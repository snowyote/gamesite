Seq = require 'seq'
Model = require './model'
User = require './user'

module.exports = class Game extends Model
  @collection_name: 'games'

  @attrs: ['black', 'white', 'state']

  @make: (black, white, next) ->
    create = (args...) => @create args...

    # validate input
    if black == white
      return next("Don't play with yourself")

    Seq()
      .par_((next) -> User.find black, next)
      .par_((next) -> User.find white, next)
      .seq_((_, black_user, white_user) ->
        return next("Couldn't find black player") unless black_user?
        return next("Couldn't find white player") unless white_user?

        attrs =
          state: 'new'
          black: black
          white: white

        create attrs, next
        )
      .catch((err) ->
        # @TODO this ensures we call the callback once-and-only-once
        # but it's grotty.  I'll use promises once Model supports
        # promises.
        next(err, null) if next?
        next = null)
