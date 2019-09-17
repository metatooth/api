require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'sinatra'

require_relative './models/user'
require_relative './models/task'
require_relative './models/note'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://metaspace:metaspace@localhost:5432/metaspace_development')

DataMapper.finalize
DataMapper.auto_upgrade!