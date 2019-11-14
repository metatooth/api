# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'dm-rspec'
require 'factory_bot'
require 'rack/test'
require 'rspec'
require 'dm-transactions'
require 'database_cleaner'

require_relative '../init'

require_relative '../app/controllers/application_controller'
require_relative '../app/controllers/orders_controller'
require_relative '../app/controllers/users_controller'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include DataMapper::Matchers

  config.include FactoryBot::Syntax::Methods

  #config.use_transactional_fixtures = true

  config.before(:suite) do
    FactoryBot.find_definitions
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  def app
    OrdersController
  end
end
