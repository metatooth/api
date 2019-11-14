# frozen_string_literal: true

class Product
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator, unique: true
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :account

  validates_uniqueness_of :locator
end
