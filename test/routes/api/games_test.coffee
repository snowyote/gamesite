GamesController = require('../../../lib/routes/api/games.coffee')

setup_db()

describe 'GamesController', ->
  describe '#index', ->
    it 'should list games of the queried state', ->
    it 'should not list games not of the queried state', ->
    it 'should 500 on a db error', ->
  describe '#show', ->
    it 'should show a game', ->
    it 'should 404 on a game that doesn\'t exist', ->
    it 'should 500 on a db error', ->
  describe '#versus', ->
    it 'should create a game', ->
    it 'should 406 on invalid params', ->
