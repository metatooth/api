require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'dm-validations'
require 'sinatra'

require_relative './app/models/locator'

require_relative './app/models/account'
require_relative './app/models/customer'
require_relative './app/models/user'
require_relative './app/models/address'
require_relative './app/models/product'
require_relative './app/models/order'
require_relative './app/models/order_item'
require_relative './app/models/invoice'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://metaspace:metaspace@localhost:5432/metaspace_development')

DataMapper.finalize
DataMapper.auto_upgrade!