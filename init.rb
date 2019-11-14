# frozen_string_literal: true

require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'dm-validations'
require 'dm-serializer'
require 'dm-timestamps'
require 'sinatra'
require 'pony'

require_relative './app/models/locator'

require_relative './app/models/account'
require_relative './app/models/api_key'
require_relative './app/models/customer'
require_relative './app/models/user'
require_relative './app/models/address'
require_relative './app/models/product'
require_relative './app/models/order'
require_relative './app/models/order_item'
require_relative './app/models/invoice'

# DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, ENV['DATABASE_URL'])

DataMapper.finalize
DataMapper.auto_upgrade!
