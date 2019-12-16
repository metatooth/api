# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'dm-rspec'
require 'factory_bot'
require 'rack/test'
require 'rspec'
require 'dm-transactions'
require 'database_cleaner'
require 'uri'
require 'pry-remote'

require_relative '../init'

module Helpers
  def json_body
    JSON.parse(last_response.body)
  end
end

module RSpecMixin
  include Rack::Test::Methods
  def app
    App
  end
end

RSpec::Matchers.define(:redirect_to) do |url|
  match do |response|
    location = response.headers['Location']
    uri = URI.parse(location) if location
    response.status.to_s[0] == '3' && uri.to_s == url
  end
end

RSpec.configure do |config|
  Pony.override_options = { via: :test }

  config.include Helpers
  config.include Rack::Test::Methods
  config.include DataMapper::Matchers
  config.include RSpecMixin
  config.include FactoryBot::Syntax::Methods

  # config.use_transactional_fixtures = true

  config.before(:each) do
    header 'Accept', 'application/vnd.metaspace.v1+json'
  end

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
end
