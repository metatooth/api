# frozen_string_literal: true

require 'securerandom'

# An API Key model.
class ApiKey
  include DataMapper::Resource
  has n, :access_tokens

  property :id, Serial, index: true
  property :api_key, String, length: 32, index: true, required: true
  property :active, Boolean, default: true, required: true
  property :created_at, DateTime
  property :updated_at, DateTime

  before :valid?, :generate!

  def self.activated
    all(active: true)
  end

  def disable
    update(active: false)
  end

  def to_s
    "#{id}:#{api_key}"
  end

  private

  def generate!
    return unless api_key.nil?

    self.api_key = SecureRandom.hex
    self.created_at = DateTime.now
    self.updated_at = DateTime.now
  end
end