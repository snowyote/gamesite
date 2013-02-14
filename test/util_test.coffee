Util = require '../lib/util'

MongoClient = require('mongodb').MongoClient
Config      = require('config').Top

db = null
beforeEach (done) ->
  unless db?
    MongoClient.connect Config.Database, (err, _db) ->
      db = _db
      done()
  else
    done()

describe 'Util', ->
  describe 'find_user', ->
    it 'should find an existing user', ->
    it 'should return null when a user doesn\'t exist', ->
  describe 'update_user', ->
    it 'should update an existing user', ->
    it 'should raise an error if the user doesn\'t exist', ->
    it 'should not allow updating certain properties', ->
  describe 'render_user', ->
    it 'should show a user in the format expected', ->
  describe 'find_game', ->
    it 'should find an existing game', ->
    it 'should return null when a game doesn\'t exist', ->
  describe 'render_game', ->
    it 'should show a game in the format expected', ->
  describe 'make_game', ->
    it 'should save a game to the database', ->
    it 'should propagate database errors', ->
  describe 'create_game', ->
    it 'should fail if black doesn\'t exist', ->
    it 'should fail if white doesn\'t exist', ->
    it 'should fail if black and white are the same', ->
    it 'should create a game in the "new" state', ->
    it 'should save the game to the database', ->
    it 'should propagate database errors', ->
