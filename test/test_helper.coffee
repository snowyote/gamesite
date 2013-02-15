chai = require 'chai'

global.expect = chai.expect
global.assert = chai.assert
global.should = chai.should()

class global.MockRequest
  constructor: (@data) ->

class global.MockResponse
  constructor: (@on_send) ->
  status: (@stat) ->
  send: (@body) ->
    @on_send(@stat, @body)

database = require '../lib/database'
global.db = null

global.setup_db = ->
  before (done) ->
    database.open()
      .then((_db) -> global.db = _db; done(null))
      .fail((err) -> done(err))
  after (done) ->
    database.close().then(done)

global.broken_db =
  collection: (_) -> this
  findOne: (_, next) -> next("Oh no")
  save: (_, next) -> next("Holy crap")
  update: (_i, _dont, _care, next) -> next("Everything's on fire")
