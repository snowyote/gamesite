chai = require 'chai'

global.expect = chai.expect
global.assert = chai.assert
global.should = chai.should()

class MockRequest
  constructor: (@data) ->

class MockResponse
  constructor: (@on_send) ->
  status: (@stat) ->
  send: (@body) ->
    @on_send(@stat, @body)
