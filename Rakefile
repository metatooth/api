# frozen_string_literal: true

require_relative 'init'

require 'rom/sql/rake_task'
require 'securerandom'

namespace :db do
  task :setup do
    configuration = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
    ROM::SQL::RakeSupport.env = configuraion
  end
end

# tasks useful to administrators
namespace :admin do
  # creates an API KEY for clients to use
  task :generate_key do
    api_keys = MAIN_CONTAINER.relations[:api_keys]
    create = api_keys.command(:create_api_key)
    create.call(api_key: SecureRandom.hex)
    last = api_keys.to_a.last
    puts "#{last[:id]}:#{last[:api_key]}"
  end
end
