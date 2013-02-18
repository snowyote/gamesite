chai = require 'chai'

global.expect  = chai.expect
global.assert  = chai.assert
global.should  = chai.should()
global.sinon   = require 'sinon'
global.request = require 'supertest'

class global.MockRequest
  constructor: (@data) ->

class global.MockResponse
  constructor: (@on_send) ->
  status: (@stat) ->
  send: (@body) ->
    @on_send?(@stat, @body)

database = require '../lib/database'

global.setup_db = (next) ->
  before (done) ->
    database.open()
      .then((_db) -> next(null, _db); done(null))
      .fail((err) -> done(err))
  # after (done) ->
  #   database.close().then(done)

global.broken_db =
  collection: (_) -> this
  findOne: (_, next) -> next("Oh no")
  find: (_, next) -> next("Run! Mustard!")
  save: (_, next) -> next("Holy crap")
  update: (_i, _dont, _care, next) -> next("Everything's on fire")
  remove: (_, next) -> next()
