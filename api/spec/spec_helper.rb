# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'dm-rspec'
require 'factory_bot'
require 'rack/test'
require 'rspec'

require_relative '../init'

require_relative '../app/controllers/application_controller'
require_relative '../app/controllers/orders_controller'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include DataMapper::Matchers

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  def app
    OrdersController
  end
end
