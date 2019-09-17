require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'sinatra'

require_relative './user'
require_relative './task'
require_relative './note'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://metaspace:metaspace@localhost:5432/metaspace_development')

DataMapper.finalize
DataMapper.auto_upgrade!