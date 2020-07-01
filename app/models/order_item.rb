# frozen_string_literal: true

# An OrderItem model.
class OrderItem
  include DataMapper::Resource
  belongs_to :order
  belongs_to :product

  property :id, Serial, index: true
  property :locator, Locator, unique: true
  property :quantity, Integer, required: true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
  validates_presence_of :quantity
end