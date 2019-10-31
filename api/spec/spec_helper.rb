require 'dm-rspec'

require_relative '../init'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include(DataMapper::Matchers)
end