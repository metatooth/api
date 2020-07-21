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
require 'rack/accept'

# The Sinatra application
class App < Sinatra::Base
  set :app_file, __FILE__
end

Dir.glob('./app/{helpers,routes,models}/*.rb').sort.each { |file| require file }

#DataMapper::Logger.new($stdout, :debug)
#DataMapper::Model.raise_on_save_failure = true

DataMapper.setup(:default, ENV['DATABASE_URL'])

DataMapper.finalize
DataMapper.auto_upgrade!
