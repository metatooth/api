# frozen_string_literal: true

# An OrderItem model.
class OrderItem
  include DataMapper::Resource

  property :id, Serial, index: true
  property :locator, Locator, unique: true 
  property :quantity, Integer, required: true
  property :created_at, DateTime, required: true
  property :updated_at, DateTime, required: true
  property :deleted, ParanoidBoolean
  property :deleted_at, ParanoidDateTime

  belongs_to :order
  belongs_to :product

  validates_uniqueness_of :locator
  validates_presence_of :quantity
end
