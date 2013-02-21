Model = require './model'
_ = require 'underscore'
md5 = require 'MD5'

module.exports = class User extends Model
  @collection_name: 'users'
  @attrs: ['name', 'email', 'online']
  mail_hash: ->
    return "00000000000000000000000000000000" unless @email?
    md5(@email.trim().toLowerCase())
  render: -> _.extend _.omit(super(), 'email'), {mail_hash: @mail_hash()}
  render_for_self: -> _.extend @render(), {email: @email}
