# frozen_string_literal: true

require_relative 'locator'

# An Order model.
class Order
  include DataMapper::Resource
  belongs_to :customer
  belongs_to :bill, 'Address'
  belongs_to :ship, 'Address'
  has n, :order_items

  property :id, Serial, index: true
  property :locator, Locator
  property :shipped_impression_kit_at, DateTime
  property :received_impression_kit_at, DateTime
  property :shipped_custom_night_guard_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted, ParanoidBoolean, default: false, lazy: false
  property :deleted_at, ParanoidDateTime

  validates_uniqueness_of :locator
end
