# frozen_string_literal: true

require_relative 'locator'

# The Revision model
class Revision
  include DataMapper::Resource
  belongs_to :plan

  property :id, Serial, index: true
  property :locator, Locator, unique: true
  property :number, Integer
  property :description, String
  property :location, String, length: 2048
  property :mime_type, String, length: 256
  property :service, String, length: 256
  property :bucket, String, length: 256
  property :s3key, String, length: 2048
  property :etag, String, length: 36
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
  validates_presence_of :plan, :number, :location
end
