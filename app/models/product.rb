# frozen_string_literal: true

# The product model, SKUs live here.
class Product
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator, unique: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  belongs_to :account

  validates_uniqueness_of :locator
end
