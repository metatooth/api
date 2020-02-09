# frozen_string_literal: true

# The product model, SKUs live here.
class Product
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator, unique: true
  property :name, String
  property :description, String
  property :price, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
  validates_presence_of :name
end
