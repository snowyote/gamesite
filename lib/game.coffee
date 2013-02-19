Q = require 'q'
Model = require './model'
User = require './user'

module.exports = class Game extends Model
  @collection_name: 'games'

  @attrs: ['black', 'white', 'state']

  @pmake: (black, white) ->
    create = (attrs) => @create attrs

    # validate input
    if black == white
      return Q.fcall -> throw new Error "Don't play with yourself"

    Q.all([User.find(black), User.find(white)]).
      spread (black_user, white_user) ->
        throw new Error("Couldn't find black player") unless black_user?
        throw new Error("Couldn't find white player") unless white_user?
        create {state: 'new', black: black, white: white}

  @make: (black, white, next) ->
    @pmake(black, white).then(((model) -> next(null, model)), ((err) -> next(err)))