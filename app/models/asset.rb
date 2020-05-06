# frozen_string_literal: true

require_relative 'locator'

# An Asset model.
class Asset
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator
  property :url, String, length: 2048, required: true
  property :name, String, length: 256
  property :mime_type, String, length: 256
  property :created_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator, :url
end
