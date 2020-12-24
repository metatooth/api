# frozen_string_literal: true

require 'rack/accept'
require 'rom'
require 'rom-sql'
require 'sinatra'

# The Sinatra application
class App < Sinatra::Base
  set :app_file, __FILE__
end

Dir.glob('./app/{commands,helpers,routes,relations,repositories}/*.rb').each do |f|
  require f
end

configuration = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
configuration.register_relation(AccessTokens, Addresses, ApiKeys, Assets)
configuration.register_relation(OrderItems, Orders, Plans, Products, Revisions)
configuration.register_relation(Users)
configuration.register_command(CreateApiKey, GenerateKey)

MAIN_CONTAINER = ROM.container(configuration)

