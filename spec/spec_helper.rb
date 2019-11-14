ENV['RACK_ENV'] = 'test'

require 'dm-rspec'
require 'factory_bot'
require 'rack/test'
require 'rspec'

require_relative '../init'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include DataMapper::Matchers

  config.include FactoryBot::Syntax::Methods
  
  config.before(:suite) do
    FactoryBot.find_definitions
  end

end