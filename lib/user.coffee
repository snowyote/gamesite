Model = require './model'
_ = require 'underscore'
md5 = require 'MD5'

module.exports = class User extends Model
  @collection_name: 'users'
  @attrs: ['name', 'email']
  mail_hash: -> md5(@email)
  render: -> _.extend _.omit(super(), 'email'), {mail_hash: @mail_hash()}
  render_for_self: -> _.extend @render(), {email: @email}
